#!/bin/sh
echo "********* Set Server Environment ********"

sudo mkdir -p /var/aws
sudo chmod +x /var/coolpay/*
sudo chmod +x /var/aws

echo "********* Install Bash Profile ********"

sudo cp -R /var/coolpay/common/bash_profile /var/aws
echo "if [ -f /var/aws/bash_profile ]; then" >> /etc/profile
echo " . /var/aws/bash_profile" >> /etc/profile
echo "fi" >> /etc/profile

echo "********* Update LANG Environment ********"

echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment

echo "********* Update MOTD ********"

sudo rm -rf /etc/update-motd.d/*
sudo cp -R /var/coolpay/common/00-dynamic /etc/update-motd.d/
sudo chmod +x /etc/update-motd.d/*

echo "********* Install base application ********"

sudo yum-config-manager --enable epel
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sudo yum install -y docker gcc-c++ pcre-dev pcre-devel zlib-devel make jq npm awslogs python-pip aws-cli nc telnet htop svn perl-libwww-perl pinentry rng-tools sysstat
sudo yum update --security --exclude=kernel* -y

echo "********* Set Default users ********"

for file in /var/coolpay/credentials/keys/*
do bname=$(basename $file) && sh /var/coolpay/credentials/access/add_user_ami.sh $bname
done

echo "********* Set docker root credential ********"

sudo mkdir -p /root/.docker/
sudo cp -R /var/coolpay/common/config.json /root/.docker/
sudo chmod +x /root/.docker/
sudo groupadd deploy
sudo usermod -g deploy backend-services
sudo usermod -a -G docker backend-services

echo "********* Set docker container storage ********"

sudo mkdir -p /var/log/api
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/sysconfig/docker
sudo cp -R /var/coolpay/production/common/docker /etc/sysconfig/
sudo mkdir -p /opt/docker/devicemapper/devicemapper
sudo service docker start
sudo chkconfig docker on

echo "********* API Deploy script ********"

sudo mkdir -p /opt/touche/bin
sudo chown -R gitlab. /opt/touche

sudo docker pull touche/api:master
sudo cp -R /var/coolpay/production/api/ami/deploy/deploy.sh /opt/touche/bin/


echo "********* Install Filebeat ********"

cd ~
sudo curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.3.0-x86_64.rpm
sudo rpm -vi filebeat-5.3.0-x86_64.rpm
sudo rm -rf /etc/filebeat/*
sudo cp -R /var/coolpay/production/common/filebeat* /etc/filebeat/

sudo chkconfig filebeat on
sudo service filebeat start


echo "********* Install AWS CloudWatch monitoring ********"

sudo mkdir -p /var/aws/cloudwatch
cd /var/aws/cloudwatch
sudo wget http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip
sudo unzip CloudWatchMonitoringScripts-1.2.1.zip
sudo rm -rf CloudWatchMonitoringScripts-1.2.1.zip

echo "********* Cleanup resources ********"

cd /var/coolpay/
sudo find -maxdepth 1 ! -name credentials -exec rm -rf {} \;

cd /var/coolpay/credentials/access/
sudo find -maxdepth 1 ! -name add_user_ami.sh ! -name remove_user.sh -exec rm -rf {} \;
