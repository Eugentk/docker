#!/bin/sh
echo "========================================Start========================================="
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common awscli
# Add package signing key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# Add repository
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# Install docker stable version
sudo apt-get update
sudo apt-get -y install docker-ce
# Start docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -a -G docker ubuntu
echo "========================================Finish========================================="