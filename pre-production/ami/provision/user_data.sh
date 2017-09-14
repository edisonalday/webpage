#!/bin/bash -x
sudo yum install -y git
sudo yum update -y
sudo git clone https://ealday:tLslxijtAtdczKBJolxyN@github.com/edisonalday/webpage.git /var/web
sudo sh /var/webpage/ami/provision/install_web.sh
