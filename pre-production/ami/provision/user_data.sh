#!/bin/bash -x
sudo yum install -y git
sudo yum update -y
sudo git clone https://github.com/edisonalday/webpage.git /var/web
sudo sh /var/web/pre-production/ami/provision/install_web.sh
