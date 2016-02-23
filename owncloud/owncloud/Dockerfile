FROM alpine-nginx
MAINTAINER GP Orcullo <kinsamanka@gmail.com>

RUN apk add -U php-fpm owncloud-pgsql owncloud-videoviewer owncloud-tasks \
        owncloud-texteditor owncloud-calendar owncloud-contacts ca-certificates 

ADD run.sh /

RUN rm -f /etc/owncloud/config.php

EXPOSE 80 443
VOLUME ["/DATA"]

CMD ["/run.sh"] 
