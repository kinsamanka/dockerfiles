FROM	kinsamanka/docker-qemu-chroot
MAINTAINER GP Orcullo <kinsamanka@gmail.com>

ENV	LOCAL_MIRROR http://mirror.nus.edu.sg/Debian/
ENV	MIRROR http://http.debian.net/debian/
ENV	HOSTNAME machinekit
ENV	ROOT /mnt/rootfs
ENV	IMAGE /mnt/OdroidC1-machinekit-1.0.img
ENV	DEBOOTSTRAP_ARGS --arch=armhf --no-check-gpg wheezy
ENV	CHROOT proot -q qemu-arm-static -r
ENV	LOOPDEV /dev/loop7
ENV	CUSTOM_APP custom_apps.sh
ENV	CUSTOM_IMG custom_image.sh
ENV	DEFUSR mk
ENV	DEFPWD machinekit

VOLUME ["/data"]
VOLUME ["/mnt"]

RUN	apt-get update && \
	apt-get install -y rsync
ADD	install.sh /usr/bin/
ADD	dovetail.key debian-mk-wallpaper.svg ssh_gen_host_keys /tmp/
CMD	install.sh
