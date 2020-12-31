#!/bin/bash

# [C] Beka Chkhaidze
# [4] Ubuntu
# [@] 29/12/2020

if [ $EUID -ne 0 ]; then
	echo "ERROR: Please run script as root"
	exit 1
fi

echo "Making original configs' backups..."
cp /etc/gdm3/custom.conf{,.bak}
cp /etc/pam.d/gdm-password{,.bak}

echo "Editing config..."
sed 's/\[Security\]/AllowRoot = true\nAllowRemoteRoot = true/g' -i /etc/gdm3/custom.conf
sed 's/auth    required    pam_succeed_if.so user != root quiet_success/# &/g' -i /etc/pam.d/gdm-password

echo "Only reboot is left"

while [[ -z "$prompt" ]]; do
	read -p "Do you want me to reboot system[Y/n]: " prompt
done

case ${prompt,,} in
	y)	reboot ;;
esac
