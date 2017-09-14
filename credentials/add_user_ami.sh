#!/bin/sh
echo "========== Add User"
if [ $(id -u) -eq 0 ]; then
	if [[ -z "$1" ]]; then
		read -p "========== Enter username : " USERNAME
	else
		USERNAME=$1
	fi
	if [[ -z "$USERNAME" ]]; then
		echo "========== Error: No User"
		exit 1
	fi
	sudo useradd $USERNAME
	sudo mkdir /home/$USERNAME/.ssh
    aws s3 cp s3://coolpay-infrastructure/development/credentials/$USERNAME /home/$USERNAME/.ssh/authorized_keys --recursive
	sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
	sudo chmod 700 /home/$USERNAME/.ssh
	sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys
	sudo chsh -s /bin/bash $USERNAME
	SUDOER="$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL"
	if grep -Fxq "$SUDOER" /etc/sudoers
		then
		sudo echo "========== User Already Exists in Sudoers"
	else
		sudo echo $SUDOER >> /etc/sudoers
	fi
	sudo chmod 0440 /etc/sudoers
else
	sudo echo "========== Error: Only root may add a user to the system"
	exit 2
fi
