#!/bin/bash

function check_root {
	if [ `id -u` -ne 0 ]; then
		echo "Please run as root"
		exit
	fi
}

function packages {
	echo -n "Updating packages... "
	apt-get update > /dev/null 2>&1
	echo "Done"

	echo "Upgrading packages... "
	apt-get upgrade --show-upgraded
}

function hostname {
	old_hostname=$(cat /etc/hostname)
	hostname_repeat=" "

	while [ "$hostname" != "$hostname_repeat" ]; do 
		hostname=""
		while [ ${#hostname} -lt 2 ] || [ "$hostname" = "$old_hostname" ]; do
			echo -n "New hostname: "
			read hostname

			if [ ${#hostname} -lt 2 ]; then
				echo "Too short, try again"
			fi

			if [ "$hostname" = "$old_hostname" ]; then
				echo "Hostname cannot be the current hostname, try again"
			fi
		done

		echo -n "Repeat hostname: "
		read hostname_repeat

		if [ "$hostname" != "$hostname_repeat" ]; then
			echo "Hostnames don't match, try again"
		fi
	done

	echo -n "Setting hostname to '$hostname'... "
	echo "$hostname" > /etc/hostname
	echo "Done"

	# update hosts file to reflect our new hostname
	echo -n "Updating hostname in /etc/hosts... "
	sed -i "s/$old_hostname/$hostname/" /etc/hosts
	echo "Done"
}

function ssh_keys {
	echo -n "Regenerating SSH keys... "
	rm /etc/ssh/ssh_host_*
	dpkg-reconfigure openssh-server > /dev/null 2>&1
	echo "Done"
}

# check if we are running as root
check_root

# update packaages
packages

# change hostname
hostname

# regenerate ssh keys
ssh_keys

# done!
echo "Enjoy your newly configured machine! Please restart before doing anything further."
