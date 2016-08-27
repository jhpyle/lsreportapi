#! /bin/bash

if [ -f /etc/letsencrypt/lra_using_lets_encrypt ]; then
    supervisorctl --serverurl http://localhost:9001 stop apache2
    cd /opt/letsencrypt
    ./letsencrypt-auto renew
    /etc/init.d/apache2 stop
    supervisorctl --serverurl http://localhost:9001 start apache2
fi
