#!/bin/bash

# Run a new docker image for alpine/socat
docker run -d --restart=always -p 127.0.0.1:2376:2375 --network jenkins -v /var/run/docker.sock:/var/run/docker.sock alpine/socat tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock

# Get its IP Address
docker inspect <container_id> | grep IPAddress

