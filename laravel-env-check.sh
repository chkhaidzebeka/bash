#!/bin/bash

# [C] Beka Chkhaidze
# [@] 17.05.2020
# [4] Debian based 0S
# -------------------
# Check environment for Laravel

w=$(tput setaf 3)	# warning
s=$(tput setaf 2)	# success
r=$(tput sgr 0)		# reset

extensions=(
	BCMath Ctype
	JSON Mbstring
	OpenSSL PDO Fileinfo
	Tokenizer XML
)

which php &> /dev/null || {
    echo "${w}PHP is not installed.${r}" >&2
    exit 1
}

php_version=$(
	awk '/PHP [0-9]/ { print substr($2,1,3) }' <<< $(php -v)
)

function check_extensions {
	for ext in ${extensions[@]}; do

		echo -en "Checking extension: "$ext":\t\t"
		php -m | grep -iw $ext &> /dev/null

		[ $? -eq 0 ] && echo  "${s}[ OK ]" || {
			name=${ext,,}	# to lowercase
			echo -en "${w}not instsalled (installing)\n"
			sudo apt-get install php${php_version}-${name} -y &> /dev/null
			[ $? -eq 0 ] || echo "Failed to install $name" >&2
		}

		echo -n ${r}
	done
}

echo -en "Checking version:\t\t\t"
[[ $php_version =~ ^7.[3-9]$ ]] && echo "${s} $php_version${r}"|| {
	echo "${w}ERROR: Current PHP version is not supported.${r}" >&2
	exit 1
}

check_extensions

echo -en "Checking composer\t\t\t"
which composer &> /dev/null && echo "${s}[ OK ]${r}" || sudo apt-get install composer -y &> /dev/null

exit 0
