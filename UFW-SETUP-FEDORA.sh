#!/bin/bash

set -e

UFW_BEFORE=/etc/ufw/before.rules
LOG_FILE=/tmp/ufw.log
WHITELIST_IPS=/opt/whitelist.ips

ECHO_PATH=$(which echo)
UFW_PATH=$(which ufw)

if [[ $EUID -ne 0 ]]; then
	echo "please run as root" >&2
	exit 1
fi


if ! [[ -f $UFW_BEFORE ]]; then
	echo "ERROR: Can't find \"$UFW_BEFORE\"" >&2
	exit 2
fi

if ! [[ -f $WHITELIST_IPS ]]; then
	echo "ERROR: Can't find \"$WHITELIST_IPS\"" >&2
	exit 2
fi

echo -e "\n------ $(date +%s) ------\n" >> $LOG_FILE

function echo {
	local str="$@"
	local len=${#str}
	let len+=4

	$ECHO_PATH "[+] $str"
	for i in $(seq $len); do $ECHO_PATH -n "-";done
	$ECHO_PATH
}

function ufw {
	$UFW_PATH "$@" &>> $LOG_FILE
	$ECHO_PATH >> $LOG_FILE
}

echo "UFW firewall setup"

echo "setting up default rules"
ufw default reject incoming
ufw default allow outgoing

echo "disabling ICMP input(ping)"
sed -i -E 's/(-A ufw-before-input -p icmp --icmp-type .* -j )ACCEPT/\1DROP/g' $UFW_BEFORE


echo "deleting all rules and setting up custom"
count=$(ufw status numbered | grep '^\[' | wc -l)
for i in $(seq $count);do $ECHO_PATH y | ufw delete 1;done

echo "enabling HTTP/HTTPS service"
ufw allow http
ufw allow https

echo "enabling ssh connection from specific IP"
ssh_port=$(grep -E 'Port\s[0-9]{2,}' /etc/ssh/sshd_config | tr -dc '[[:digit:]]')
while read ip; do
	ufw allow from $ip to any port $ssh_port
done < $WHITELIST_IPS

echo "reloading UFW"
$ECHO_PATH y | ufw enable
$ECHO_PATH y | ufw reload
