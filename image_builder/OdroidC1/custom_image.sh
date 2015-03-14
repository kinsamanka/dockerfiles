#!/bin/sh -ex

# copy boot files
cp -a /data/boot/dtbs /data/boot/boot.ini ${ROOT}/boot

# create sparse file
rm -f ${IMAGE}
dd if=/dev/zero of=${IMAGE} count=0 bs=1 seek=2021654528

# create partitions
fdisk ${IMAGE} <<EOF
n
p
1


w
EOF

# make sure loop device is clean
losetup -d ${LOOPDEV} || true

# format partitions
losetup ${LOOPDEV} ${IMAGE} -o $((2048*512))
mkfs.ext4 -L Machinekit ${LOOPDEV}

# mount partitions
mkdir -p mnt_root
mount ${LOOPDEV} mnt_root

# populate ROOT
echo "populate root..."
rsync -a ${ROOT}/ mnt_root

umount mnt_root
losetup -d ${LOOPDEV}

# install u-boot
losetup ${LOOPDEV} ${IMAGE}
dd if=/data/boot/bl1.bin.hardkernel of=${LOOPDEV} bs=1 count=442
dd if=/data/boot/bl1.bin.hardkernel of=${LOOPDEV} bs=512 skip=1 seek=1
dd if=/data/boot/u-boot.bin of=${LOOPDEV} bs=512 seek=64
losetup -d ${LOOPDEV}

rm -f ${IMAGE}.bz2
bzip2 -9 ${IMAGE}
mv ${IMAGE}.bz2 /data