#!/bin/sh
	echo "========== Remove User"
	if [ $(id -u) -eq 0 ]; then
		read -p "========== Enter username : " USERNAME
		if [[ -z "$USERNAME" ]]; then
			echo "No User"
			exit 1
		fi
		rm -rf /home/$USERNAME
		userdel $USERNAME
		grep -v "$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" /etc/sudoers > /tmp/sudoers; mv -f /tmp/sudoers /etc/sudoers
		chmod 0440 /etc/sudoers
		echo "========== Removed $USERNAME"
	else
		echo "========== Error: Only root may remove a user to the system"
		exit 2
	fi