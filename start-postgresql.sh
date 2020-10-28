#!/bin/sh

if [ ! -d "${PGDATA}/base" ] ; then
    mkdir -p "${PGDATA}"  2>/dev/null
    chown -Rf postgres:postgres "${PGDATA}"
    chmod 0700 "${PGDATA}"
    cd "${PGDATA}"
    su -c "/usr/bin/initdb --pgdata ${PGDATA}" postgres
    PGPASSWORD=${PGPASSWORD:-$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)}
    su postgres -c "/usr/bin/postgres --single -D $PGDATA -c config_file=$PGDATA/postgresql.conf " << EOF
CREATE DATABASE fusionpbx;
CREATE DATABASE freeswitch;
CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$PGPASSWORD';
CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$PGPASSWORD';
GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;
GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;
GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;
EOF

# change default postgresql port as it's already used by Unifi
sed -i "s/#port = 5432/port = ${PGPORT}/" ${PGDATA}/postgresql.conf
sed -i "s/5432/${PGPORT}/" /var/www/fusionpbx/core/install/resources/page_parts/install_config_database.php

# generate self signed cert for ngix
openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=Company, Inc./CN=mydomain.com" -addext "subjectAltName=DNS:mydomain.com" -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt;

# update nginx with ssl cert

sed -i "/listen 9180;/i listen $SSLPORT ssl http2 default_server;\nlisten \[\:\:\]\:$SSLPORT ssl http2 default_server;\nssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;\nssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;" /etc/nginx/conf.d/default.conf

#        listen 9181 ssl http2 default_server;
#        listen [::]:9181 ssl http2 default_server;
#        ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
#        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

# reload nginx with ssl changes
/usr/sbin/nginx -s reload;

fi

su postgres -c "/usr/bin/postgres -D ${PGDATA} -c config_file=${PGDATA}/postgresql.conf"
