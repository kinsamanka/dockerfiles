## mk-qemu-cross
# Machinekit build environment based on QEMU cross compiler for Armhf

This is an implementation of QEMU User emulation on a Docker container using [proot](http://proot.me)

### Usage

Download this docker container using the following commands
```
docker pull kinsamanka/mk-qemu-cross
```

To use the cross compiler environment, run the following docker command:
```
docker run -i -t --rm=true kinsamanka/mk-qemu-cross
```
This command will drop you to the chroot environment. You can verify that you're
 running under an emulated environment by issuing the following command: `uname -
m`, it should return `armv7l`

### Compiling Machinekit
```
cd /usr/src/
git clone --depth=1 https://github.com/machinekit/machinekit.git
cd machinekit

./autogen.sh

./configure \
	CC=arm-linux-gnueabihf-gcc \
	CXX=arm-linux-gnueabihf-g++ \
	 < ... whatever flags ... >
     
make -j4
```
To compile using the native compiler, remove the `CC` and `CXX` flags.
### Exporting the results
The compilation results are normally exported using `netcat`:
```
tar cvf - . | nc -l -q1 -p <port> <destination ip>
```

The other option is to bind a host directory to the chroot container. The following command will bind the ***host dir*** to the `/mnt` directory:
```
docker run -v <host dir>:/opt/rootfs/mnt -i -t --rm=true kinsamanka/mk-qemu-cross
```
Note that the ***host dir*** must be specified using its full pathname.

### Modifying the container
Note that any changes made on the container will be lost after exiting it due to the `--rm=true` switch.

To make permanent changes to the container, run the following command:
```
docker run -i -t kinsamanka/mk-qemu-cross
```
Make the desired changes and take note of the hostname. The hostname is the 12 digit hex number (e.g. root@***2524b7a328a3***:/#).

After exiting the container, commit the changes by running the following command:
```
docker commit <12 digit id> <container name>
```
Example:
```
docker commit 2524b7a328a3 MyContainer
```

To use the updated container, just run:
```
docker run -i -t --rm=true MyContainer
```

