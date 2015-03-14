#!/bin/sh -ex

# setup APT
cat <<EOF > ${ROOT}/etc/apt/sources.list.d/odroid.list
deb http://0ptr.link/C1 wheezy main
EOF

# add public key
cp /data/*key ${ROOT}/tmp
${CHROOT} ${ROOT} sh -ex << EOF
apt-key add /tmp/0ptr.key
apt-get update
EOF
rm ${ROOT}/tmp/*key

# remove unneeded packages
${CHROOT} ${ROOT} sh -ex << EOF
apt-get remove -y xserver-xorg-video-mach64 xserver-xorg-video-nouveau \
    xserver-xorg-video-r128 xserver-xorg-video-radeon \
    xserver-xorg-video-vesa 
EOF

# install additional packages
${CHROOT} ${ROOT} sh -ex << EOF
apt-get -y install --no-install-recommends fake-hwclock fbset \
	linux-image-3.10.70-rt71 \
	machinekit-rt-preempt machinekit-dev machinekit-posix
EOF

# copy kernel
cp ${ROOT}/boot/uImage* ${ROOT}/boot/uImage

# setup fbdev
cp /data/fbdev ${ROOT}/etc/init.d/fbdev
LC_ALL=C LANGUAGE=C LANG=C ${CHROOT} ${ROOT} insserv /etc/init.d/fbdev

# onboard lan under rt-preempt is still broken
sed -i 's/eth0/usbnet0/g' ${ROOT}/etc/network/interfaces

# enable autologin serial console
cat <<EOF > ${ROOT}/sbin/autologin
#!/bin/sh
exec /bin/login -f root
EOF

chmod a+x ${ROOT}/sbin/autologin
echo 'S0:23:respawn:/sbin/getty -l /sbin/autologin -n -L ttyS0 115200 vt102' \
    >> ${ROOT}/etc/inittab

# install mali Xorg driver
tar xf /data/mali.tgz -C  ${ROOT}
${CHROOT} ${ROOT} ldconfig

