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

fi

su postgres -c "/usr/bin/postgres -D ${PGDATA} -c config_file=${PGDATA}/postgresql.conf"
