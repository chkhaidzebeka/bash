#!/bin/bash

if [ $EUID -ne 0 ]; then
	echo "Please run as root" >&2
	exit 2
fi


if [ $# -eq 0 ]; then
	echo "Usage: $0 <siteName>.local <siteRoot>" >&2
	exit 2
fi

site=$1
wwwroot=$2

FILE=/etc/apache2/sites-available/${site}.conf

echo "
<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        ServerAdmin admin@${site}.local
        ServerName ${site}.local
        ServerAlias www.${site}.local
        DocumentRoot ${wwwroot}/public_html

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
" > $FILE

mkdir -p "$wwwroot"/public_html

echo "<h1>This is $site.local virtualhost</h1>" >> "$wwwroot/public_html/index.html"

a2ensite $site.conf

grep -q "$site.local" /etc/hosts
if [ $? -ne 0 ]; then
	echo -e "127.0.0.1\t${site}.local" >> /etc/hosts
fi

systemctl reload apache2
systemctl restart apache2
