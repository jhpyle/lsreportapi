FROM debian:sid
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get clean && apt-get update
RUN until apt-get -q -y install python git apache2 supervisor perl libcgi-pm-perl libjson-perl fontconfig libfontconfig1 phantomjs; do sleep 1; done
RUN mkdir -p /opt/lsreportapi && cd /opt && git clone git://github.com/casperjs/casperjs.git && ln -s /opt/casperjs/bin/casperjs /usr/local/bin/casperjs
RUN chown -R www-data.www-data /var/www && chsh -s /bin/bash www-data
RUN cd /opt && git clone https://github.com/letsencrypt/letsencrypt && cd letsencrypt && ./letsencrypt-auto --help
COPY initialize.sh /opt/lsreportapi/
COPY ls-report-api.js /opt/lsreportapi/
COPY index.pl /var/www/
COPY default-ssl.conf /opt/lsreportapi/
COPY default.conf /opt/lsreportapi/
COPY supervisor.conf /etc/supervisor/conf.d/lsreportapi.conf

USER root
RUN a2enmod ssl
RUN a2enmod rewrite
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
EXPOSE 80
EXPOSE 443

VOLUME  ["/etc/letsencrypt", "/etc/apache2/sites-available"]

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
