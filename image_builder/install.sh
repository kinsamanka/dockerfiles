#!/bin/sh -ex

start_debootstrap () {
    # reusing rootfs
    if [ -f /data/debootstrap_rootfs.tgz ]; then
        echo Reusing rootfs
        rm -rf ${ROOT}
        mkdir -p ${ROOT}
        tar xf /data/debootstrap_rootfs.tgz -C ${ROOT}
    else
        debootstrap --foreign ${DEBOOTSTRAP_ARGS} ${ROOT} ${LOCAL_MIRROR}
        ${CHROOT} ${ROOT} /debootstrap/debootstrap --second-stage --verbose
        tar czf /data/debootstrap_rootfs.tgz -C ${ROOT} .
    fi
}

setup_etc () {
    #edit hostname
    echo ${HOSTNAME} > ${ROOT}/etc/hostname
    echo '127.0.0.1\t'${HOSTNAME} >> ${ROOT}/etc/hosts

    # edit network interface
    cat << EOF > ${ROOT}/etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF
}

setup_apt () {
    cat <<EOF > ${ROOT}/etc/apt/sources.list
deb ${LOCAL_MIRROR} wheezy main contrib
deb ${LOCAL_MIRROR} wheezy-updates main contrib
deb ${LOCAL_MIRROR} wheezy-backports main contrib
deb http://security.debian.org/ wheezy/updates main contrib
EOF

    cat <<EOF > ${ROOT}/etc/apt/sources.list.d/machinekit.list
deb http://deb.dovetail-automata.com wheezy main
EOF

    # add public key
    cp /tmp/dovetail.key ${ROOT}/tmp
    ${CHROOT} ${ROOT} sh -ex << EOF
apt-key add /tmp/dovetail.key
apt-get update
EOF

    rm ${ROOT}/tmp/dovetail.key
}

disable_daemons () {
    cat <<EOF > ${ROOT}/usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF
    chmod a+x ${ROOT}/usr/sbin/policy-rc.d
}
install_base () {
    ${CHROOT} ${ROOT} sh -ex << EOF
export DEBIAN_FRONTEND=noninteractive 
apt-get -y upgrade

apt-get -y install -t wheezy-backports cython

apt-get install -y keyboard-configuration

# extra packages
apt-get -y install --no-install-recommends \
    usbmount rsync ca-certificates locales sudo openssh-server ntp vim-tiny \
    less xinit xserver-xorg-core xserver-xorg xserver-xorg-input-all \
    xserver-xorg-input-evdev iceweasel

apt-get -y install xrdp lxde lxde-icon-theme lightdm lightdm-gtk-greeter
EOF
}

configure_base () {
    # configure usbmount
    sed -i -e 's/""/"-fstype=vfat,flush,gid=plugdev,dmask=0007,fmask=0117"/g' \
        ${ROOT}/etc/usbmount/usbmount.conf

    # update sudoers
    sed -i "s/%sudo\tALL=(ALL:ALL)/%sudo\tALL=NOPASSWD:/g"  \
        ${ROOT}/etc/sudoers

    # fix ssh keys
    cp /tmp/ssh_gen_host_keys ${ROOT}/etc/init.d/
    LC_ALL=C LANGUAGE=C LANG=C ${CHROOT} \
        ${ROOT} insserv /etc/init.d/ssh_gen_host_keys

    # add user
    ${CHROOT} ${ROOT} sh << EOF
adduser --disabled-password --gecos "${DEFUSR}" ${DEFUSR}
usermod -a -G sudo,staff,kmem,plugdev,adm,dialout,cdrom,audio,video,games,users ${DEFUSR}
echo -n ${DEFUSR}:${DEFPWD} | chpasswd
EOF

    # configure NetworkManager
    sed -i 's/false/true/g' ${ROOT}/etc/NetworkManager/NetworkManager.conf

    # update wallpaper
    mkdir -p ${ROOT}/usr/share/images/desktop-base
    cp /tmp/debian-mk-wallpaper.svg ${ROOT}/usr/share/images/desktop-base/
    rm -f ${ROOT}/etc/alternatives/desktop-background
    ln -sf /usr/share/images/desktop-base/debian-mk-wallpaper.svg \
        ${ROOT}/etc/alternatives/desktop-background
    sed -i 's/login-background/debian-mk-wallpaper/g' \
        ${ROOT}/etc/lightdm/lightdm-gtk-greeter.conf
}
cleanup () {
    # cleanup APT
    rm -f ${ROOT}/var/lib/apt/lists/* || true
    LC_ALL=C LANGUAGE=C LANG=C ${CHROOT} ${ROOT} apt-get clean

    # fix APT sources
    sed -i "s^${LOCAL_MIRROR}^${MIRROR}^g" ${ROOT}/etc/apt/sources.list

    # remove our traces
    rm -f ${ROOT}/etc/resolv.conf
    echo > ${ROOT}/root/.bash_history
    rm -f ${ROOT}/usr/sbin/policy-rc.d
}

######################
# Install starts here
######################

start_debootstrap

# reuse archives
if [ -d /data/archives ]; then
    rsync -a /data/archives ${ROOT}/var/cache/apt/
fi

setup_etc
setup_apt
disable_daemons
install_base
configure_base

# run custom install
if [ -f /data/${CUSTOM_APP} ]; then
    sh -ex /data/${CUSTOM_APP}
fi

# save archives
rsync -a ${ROOT}/var/cache/apt/archives /data

cleanup

# run custom image
if [ -f /data/${CUSTOM_IMG} ]; then
    sh -ex /data/${CUSTOM_IMG}
else
    mv ${ROOT} /data
fi
