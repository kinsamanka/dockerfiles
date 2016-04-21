FROM    machinekit/mk-builder:base
MAINTAINER GP Orcullo <kinsamanka@gmail.com>

ENV	MIRROR http://http.debian.net/debian/
ENV	HOSTNAME machinekit
ENV	LOOPDEV /dev/loop7
ENV	CUSTOM_APP custom_apps.sh
ENV	CUSTOM_IMG custom_image.sh
ENV	DEFUSR mk
ENV	DEFPWD machinekit
ENV	ARCH armhf
ENV	CONF /tmp/jessie.conf
ENV	SUITE jessie
ENV	PROOT_OPTS "-b /dev/null -b /dev/zero -b /dev/pts -b /dev/shm -b /dev/urandom"

VOLUME ["/data"]
VOLUME ["/mnt"]

ADD	install.sh /usr/bin/
ADD	deb.machinekit.io.key debian-mk-wallpaper.svg jessie.conf ssh_gen_host_keys /tmp/
CMD	install.sh
