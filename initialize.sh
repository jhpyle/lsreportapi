#! /bin/bash

export LC_ALL="en_US.UTF-8"
export NCURSES_NO_UTF8_ACS=1

rm -f /etc/apache2/sites-available/000-default.conf
rm -f /etc/apache2/sites-available/default-ssl.conf
a2dissite 000-default
a2dissite default-ssl

if [ "${HOSTNAME-none}" != "none" ]; then
    if [ ! -f /etc/apache2/sites-available/lsreportapi-ssl.conf ]; then
	sed -e 's/#ServerName {{HOSTNAME}}/ServerName '"${HOSTNAME}"'/' \
	    -e 's/#ServerAdmin {{SERVERADMIN}}/ServerAdmin '"${LETSENCRYPTEMAIL}"'/' \
            /opt/lsreportapi/default-ssl.conf > /etc/apache2/sites-available/lsreportapi-ssl.conf || exit 1
	rm -f /etc/letsencrypt/lra_using_lets_encrypt
    fi
    if [ ! -f /etc/apache2/sites-available/lsreportapi-http.conf ]; then
	sed -e 's/#ServerName {{HOSTNAME}}/ServerName '"${HOSTNAME}"'/' \
	    -e 's/#ServerAdmin {{SERVERADMIN}}/ServerAdmin '"${LETSENCRYPTEMAIL}"'/' \
            /opt/lsreportapi/default.conf > /etc/apache2/sites-available/lsreportapi-http.conf || exit 1
	rm -f /etc/letsencrypt/lra_using_lets_encrypt
    fi
fi
a2ensite lsreportapi-http
a2ensite lsreportapi-ssl
cd /opt/letsencrypt
if [ -f /etc/letsencrypt/lra_using_lets_encrypt ]; then
    ./letsencrypt-auto renew
else
    ./letsencrypt-auto --apache --quiet --email ${LETSENCRYPTEMAIL} --agree-tos -d ${HOSTNAME} && touch /etc/letsencrypt/lra_using_lets_encrypt
fi
cd ~-
/etc/init.d/apache2 stop

supervisorctl --serverurl http://localhost:9001 start apache2

sleep infinity &
wait %1
