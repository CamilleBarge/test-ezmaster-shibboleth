FROM debian:jessie

RUN apt-get update \
  #&& apt-get -y install apache2=2.4.10-10+deb8u4 libapache2-mod-shib2=2.5.3+dfsg-2 \
  && apt-get -y install apache2 libapache2-mod-shib2=2.5.3+dfsg-2 \
  && apt-get clean

RUN a2enmod ssl shib2 proxy_http
RUN a2dissite 000-default
RUN a2ensite default-ssl

# generate ssl keys to be able to start the shibd service
# but these keys have to be replaced by officials ones at
# configuration step
RUN cd /etc/shibboleth/ && shib-keygen

# redirect logs to stdout
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log
RUN ln -sf /proc/self/fd/1 /var/log/apache2/error.log
RUN ln -sf /proc/self/fd/1 /var/log/shibboleth/shibd.log
RUN ln -sf /proc/self/fd/1 /var/log/shibboleth/shibd_warn.log
RUN ln -sf /proc/self/fd/1 /var/log/shibboleth/signature.log
RUN ln -sf /proc/self/fd/1 /var/log/shibboleth/transaction.log

COPY ./httpd-foreground /usr/local/bin/
CMD [ "httpd-foreground" ]

# ezmasterization of ezmaster-redis
# see https://github.com/CamilleBarge/test-ezmaster-redis/


# redis data folder dedicated to ezmaster
# because it's not yet (8 nov 2017) possible to UNVOLUME /data/db and /data/configdb
RUN mkdir -p /ezdata




# notice: httpPort is useless here but as ezmaster require it (v3.8.1) we just add a wrong port number
RUN echo '{ \
  "httpPort": 8080, \
  "configPath": "config.json", \
  "configType": "json", \
  "dataPath": "/ezdata", \
  "technicalApplication": true \
}' > /etc/ezmaster.json



EXPOSE 443
