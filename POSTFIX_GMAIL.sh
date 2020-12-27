#!/bin/bash

[ $EUID -ne 0 ] && {
	echo "run script as root" >&2
	exit 1
}

echo -e "NOTICE:\nThis will work only for gmail"; sleep .5

echo -e "updating ..."
apt-get update &> /dev/null

echo "installing reuqired softwares ..."
apt-get install postfix mailutils -y > /dev/null

echo "time to give me your credentials"
read -p 'username: ' username
read -p 'password: ' password

if [ -z "$username" ] || [ -z "$password" ];then
	echo "ERROR, username or password is empty" >&2
elif ! grep -q "@gmail.com$" <<< "$username"; then
	echo "ERROR, username doesn't end with @gmail.com" >&2
	exit 1
else
	echo "[smtp.gmail.com]:587    ${username}:${password}" > /etc/postfix/sasl_passwd
	chmod 600 /etc/postfix/sasl_passwd
fi

echo "configuring postfix ..."
cat << CONFIG >> /etc/postfix/main.cf
relayhost = [smtp.gmail.com]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_security_options =
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
CONFIG

postmap /etc/postfix/sasl_passwd
systemctl restart postfix.service

echo "finished. make sure you have enabled less secure apps"
echo "to use mail: echo \"this is test mail\" | mail -s \"TEST\" recipient@domain.com"
