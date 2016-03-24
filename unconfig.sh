#!/bin/sh

# check if we are running as root
if [ `id -u` -ne 0 ]; then
	echo "Please run as root"
	exit
fi

# delete ssh keys
/bin/rm -f /etc/ssh/ssh_host_*

# delete log files
/bin/rm -f /var/log/*

# clear bash history
/bin/rm -f /root/.bash_history
/bin/rm -f /home/adam/.bash_history

# remove self
/bin/rm -f $0

# shutdown
shutdown -h now