#!/bin/sh -ex

# create needed user/groups with same uid/gid of the shared directory
UID=$(stat -c '%u' /DATA/data)
GID=$(stat -c '%g' /DATA/data)

# create new user if not exists
uid=$(getent passwd ${UID} | cut -f1 -d':')
if [ "x$uid" = "x" ]; then
    adduser -u $UID -h /dev/null -s /bin/false -D -H nginx
    uid='nginx'
fi

# create new group if not exists
gid=$(getent group ${GID} | cut -f1 -d':')
if [ "x$gid" = "x" ]; then
    addgroup -g $GID nginx
    gid='nginx'
fi

# update configs
sed -e "s/OWNCLOUD_UID/${uid}/g" -e "s/OWNCLOUD_GID/${gid}/g" \
    /DATA/config/php-fpm.conf > /etc/php/php-fpm.conf
sed -e "s/OWNCLOUD_UID/${uid}/g" /DATA/config/nginx.conf \
    > /etc/nginx/conf/nginx.conf

# check if db is configured
PGPASSWORD=${OC_POSTGRES_ENV_POSTGRES_PASSWORD} 
res=$(PGPASSWORD=${PGPASSWORD} psql \
    -h ${OC_POSTGRES_PORT_5432_TCP_ADDR} -U ${OC_POSTGRES_ENV_POSTGRES_USER} \
    postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='mycloud'")

if [ "x$res" = "x" ]; then
    PGPASSWORD=${PGPASSWORD} psql \
    -h ${OC_POSTGRES_PORT_5432_TCP_ADDR} -U ${OC_POSTGRES_ENV_POSTGRES_USER} << EOF 
CREATE USER mycloud WITH PASSWORD '${OWNCLOUD_PASSWD}';
CREATE DATABASE owncloud TEMPLATE template0 ENCODING 'UNICODE';
ALTER DATABASE owncloud OWNER TO mycloud;
GRANT ALL PRIVILEGES ON DATABASE owncloud TO mycloud;
\q
EOF
fi

# create default config.php
[ ! -f /etc/owncloud/config.php ] \
    && cp /DATA/config/config.php /etc/owncloud/config.php \
    && chown $uid:$gid /etc/owncloud/config.php

# copy owncloud autoconfig.php if not configured
if [ "`grep "'installed' => false" /etc/owncloud/config.php`" != "" ]; then
    sed -e "s/PASSWORD/${OWNCLOUD_PASSWD}/g" /DATA/config/autoconfig.php \
        > /etc/owncloud/autoconfig.php
    chown $uid:$gid /etc/owncloud/autoconfig.php
else
    rm -f /etc/owncloud/autoconfig.php
fi

chown $uid:$gid -R /etc/owncloud /DATA/data /DATA/logs /DATA/apps
for a in data apps; do
    find /DATA/$a/ -type f -print0 | xargs -0 chmod 0640
    find /DATA/$a/ -type d -print0 | xargs -0 chmod 0750
done

# fix permissions
ocpath='/usr/share/webapps/owncloud'

mkdir -p $ocpath/data
mkdir -p $ocpath/assets

find ${ocpath}/apps -type f -print0 | xargs -0 chmod 0640
find ${ocpath}/apps -type d -print0 | xargs -0 chmod 0750

#chown -R root:${gid} ${ocpath}/
chown -R ${uid}:${gid} ${ocpath}/apps/
#chown -R ${uid}:${gid} ${ocpath}/config/
chown -R ${uid}:${gid} ${ocpath}/data/
#chown -R ${uid}:${gid} ${ocpath}/themes/
#chown -R ${uid}:${gid} ${ocpath}/assets/

chmod +x ${ocpath}/occ

if [ -f ${ocpath}/.htaccess ]; then
    chmod 0644 ${ocpath}/.htaccess
    chown root:${gid} ${ocpath}/.htaccess
fi

if [ -f ${ocpath}/data/.htaccess ]; then
    chmod 0644 ${ocpath}/data/.htaccess
    chown root:${gid} ${ocpath}/data/.htaccess
fi

php-fpm

nginx -g "daemon off;"
