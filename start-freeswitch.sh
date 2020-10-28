#!/bin/sh

while [ ! -f ${PGDATA}/postmaster.pid ]
do
    sleep 1
done
sleep 10

/usr/bin/freeswitch -u nginx -g nginx -rp -nonat -scripts /usr/share/freeswitch/scripts
