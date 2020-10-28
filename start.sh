#!/bin/sh

if [ ! -f /data/.ok ] ; then
    cp -a /data.org/* /data
    touch /data/.ok
fi

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
