#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt update -y

# Create a Docker network for Jenkins (optional)
echo "Creating a Docker network for Jenkins..."
docker network create jenkins || echo "Network already exists."

# In order to execute Docker commands inside Jenkins nodes, download and run the docker:dind
docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind --storage-driver overlay2

# !!!! BEFORE CONTINUING !!!!
#Create a Dockerfile with the following content:
echo "FROM jenkins/jenkins:2.492.1-jdk17
USER root
RUN apt-get update && apt-get install -y lsb-release python3-pip
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo \"deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable\" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins \"blueocean docker-workflow\"" > Dockerfile

# Build a new docker image from the above Dockerfile
docker build -t myjenkins-blueocean:2.492.1-1 .

# Run the created Jenkins container
echo "Starting Jenkins container..."
docker run --name jenkins-blueocean --restart=on-failure --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:2.492.1-1

echo "Jenkins is running at http://localhost:8080"
echo "Get the initial admin password using: docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword"
