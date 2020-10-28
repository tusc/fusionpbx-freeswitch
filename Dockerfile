FROM arm64v8/alpine:3.12.1

#originally based on dockerfile form kinsamanka

#ADD qemu-aarch64-static /usr/bin

ENV FP_VER 4.4.1

# needed for mod_pgsql
COPY pre_load_modules.conf.xml /tmp

RUN apk add --no-cache curl dnsmasq freeswitch-flite \
        nginx php7-curl php7-fpm php7-imap php7-json php7-mcrypt php7-odbc php7-pdo php7-pdo_pgsql \
        php7-pgsql php7-session php7-sqlite3 php7-xml php7-simplexml php7 postgresql \
        supervisor freeswitch-sounds-en-us-callie-8000 freeswitch-sounds-music-8000 freeswitch-sounds-music-32000 \
        freeswitch-sounds-en-us-callie-32000 openssl \
    && echo "pid /tmp/nginx.pid;" >> /etc/nginx/nginx.conf \
    && sed -e 's_nobody_nginx_g' \
           -e 's_127.0.0.1:9000_/tmp/fpm.sock_g' \
           -e 's_;listen.o_listen.o_g' \
           -e 's_;listen.g_listen.g_g' \
           -e 's_;listen.m_listen.m_g' \
           -i /etc/php7/php-fpm.d/www.conf \
#    && ln /usr/bin/php7 /usr/bin/php \
    && cd /var/www \
    && curl -L https://github.com/fusionpbx/fusionpbx/archive/${FP_VER}.tar.gz | tar xzf - \
    && mv fusionpbx*/ fusionpbx \
    && chown -Rf nginx:nginx fusionpbx \
    && chmod -R 755 fusionpbx/secure \
    && rm -rf /etc/freeswitch/* \
    && cp -R /var/www/fusionpbx/resources/templates/conf/* /etc/freeswitch \
    && mkdir /usr/share/freeswitch/scripts \
    && chown -R nginx:nginx /etc/freeswitch \
    && chown -R nginx:nginx /var/lib/freeswitch \
    && chown -R nginx:nginx /usr/share/freeswitch \
    && chown -R nginx:nginx /var/log/freeswitch \
    && chown -R nginx:nginx /var/run/freeswitch \
#    && sed -i 's/listen 127.0.0.1:80/listen 127.0.0.1:9180/' /etc/nginx/conf.d/default.conf \
#    && sed -i 's/listen 80/listen 9180/' /etc/nginx/conf.d/default.conf \
    && mkdir /etc/fusionpbx \
    && mkdir /run/postgresql \
    && chown postgres:postgres /run/postgresql \
    && chown -R nginx:nginx /etc/fusionpbx \
    && mkdir -p /data.org/lib /data.org/share /data \
##    && cp -rp /usr/share/freeswitch/sounds /data.org/share/freeswitch/  \
    && chmod 0777 -R /data.org \
    && cp /tmp/pre_load_modules.conf.xml  /etc/freeswitch/autoload_configs \
    && cp /tmp/pre_load_modules.conf.xml  /var/www/fusionpbx/resources/templates/conf/autoload_configs \
    && mv /etc/freeswitch /etc/fusionpbx /var/log /data.org \
    && mv /var/lib/freeswitch /data.org/lib/freeswitch \
    && mv /usr/share/freeswitch /data.org/share/freeswitch \
    && ln -sf /data/freeswitch /etc/freeswitch \
    && ln -sf /data/lib/freeswitch /var/lib/freeswitch \
    && ln -sf /data/share/freeswitch /usr/share/freeswitch \
    && ln -sf /data/fusionpbx /etc/fusionpbx \
    && ln -sf /data/log /var/log \
    && ln -sf /data.org/freeswitch /data/freeswitch \
    && ln -sf /data.org/lib /data/lib \
    && ln -sf /data.org/share /data/share \
    && ln -sf /data.org/fusionpbx /data/fusionpbx \
    && ln -sf /data.org/log /data/log \
    && touch /data/.ok
#    && apk add --no-cache freeswitch-sounds-en-us-callie-8000 freeswitch-sounds-music-8000

ENV PGDATA /data/postgresql
ENV PGPORT 15432
ENV SSLPORT 9181

VOLUME /data

ADD fusionpbx /etc/nginx/conf.d/default.conf
ADD start-freeswitch.sh /usr/bin
ADD start-postgresql.sh /usr/bin
ADD supervisord.conf /etc/
ADD start.sh /

CMD /start.sh
