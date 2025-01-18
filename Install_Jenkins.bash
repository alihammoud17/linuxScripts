#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Updating package list..."
sudo apt update -y

echo "Adding Jenkins GPG key..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "Adding Jenkins repository..."
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Updating package list after adding Jenkins repository..."
sudo apt update -y

echo "Installing Jenkins..."
sudo apt install -y jenkins

echo "Starting Jenkins service..."
sudo systemctl start jenkins

echo "Enabling Jenkins to start on boot..."
sudo systemctl enable jenkins

echo "Verifying Jenkins service status..."
sudo systemctl status jenkins --no-pager

echo "Jenkins installation is complete!"
echo "Access Jenkins at: http://<your-server-ip>:8080"
echo "To unlock Jenkins, use the following command to get the initial admin password:"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
