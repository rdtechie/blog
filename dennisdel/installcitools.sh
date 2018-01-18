#!/bin/bash
wget https://github.com/gohugoio/hugo/releases/download/v0.29/hugo_0.29_Linux-64bit.deb

yes | sudo dpkg -i hugo*.deb

hugo version

# Install Python and PIP
sudo apt-get -y update
sudo apt-get -y upgrade
#sudo apt-get install -y python3-pip
sudo apt-get -y install python-setuptools
sudo easy_install pip

# Install AWS CLI
pip install --upgrade awscli

# Configure AWS CLI
aws configure set aws_access_key_id $1
aws configure set aws_secret_access_key $2
aws configure set default.region $3
aws configure set preview.cloudfront true