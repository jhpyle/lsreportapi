# lsreportapi

Run:

    sudo yum -y update
    sudo yum -y install docker git
    sudo usermod -a -G docker ec2-user

Log off and log in again.

    git clone https://github.com/jhpyle/lsreportapi
    cd lsreportapi
    docker build -t jhpyle/mylsreportapi .
    docker run \
    --env HOSTNAME=ls.docassemble.org \
    --env LETSENCRYPTEMAIL=jhpyle@gmail.com \
    --volume lraletsencrypt:/etc/letsencrypt \
    --volume lraapache:/etc/apache2/sites-available \
    --detach --publish 80:80 --publish 443:443 jhpyle/mylsreportapi
