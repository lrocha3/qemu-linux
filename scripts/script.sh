#!/bin/bash

sudo snap install docker
sudo apt install libelf-dev 
sudo apt install libssl-dev
sudo apt-get install curl
sudo apt-get install libncurses5-dev
sudo apt install qemu-system-x86
sudo apt-get install libncurses5-dev
sudo apt install qemu

SCRIPT_PATH=$(pwd)

# BUSY BOX
cd $SCRIPT_PATH
mkdir busybox
cd busybox

wget -nc https://busybox.net/downloads/busybox-1.36.0.tar.bz2
tar -xvf busybox-1.36.0.tar.bz2

cd busybox-1.36.0
cp $SCRIPT_PATH/scripts/.busybox_config .config

make -j8
make CONFIG_PREFIX=./../busybox_rootfs install

# INIT RAM FS
cd $SCRIPT_PATH

mkdir initramfs
cd initramfs

mkdir -p bin sbin etc proc sys usr/bin usr/sbin

cp $SCRIPT_PATH/scripts/init ./init
chmod +x init

cp -a $SCRIPT_PATH/busybox/busybox_rootfs/. .

find . -print0 | cpio --null -ov --format=newc > initramfs.cpio 
gzip ./initramfs.cpio

# KERNEL

cd $SCRIPT_PATH

mkdir kernel
cd kernel

wget -nc https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.tar.xz
tar -xvf linux-5.15.tar.xz
cd linux-5.15
cp $SCRIPT_PATH/scripts/.kernel_config .config
make -j8

# QUEMU RUN

cd $SCRIPT_PATH

mkdir image
cd image

cp $SCRIPT_PATH/initramfs/initramfs.cpio.gz .
cp $SCRIPT_PATH/kernel/linux-5.15/arch/x86_64/boot/bzImage .


qemu-system-x86_64 -kernel ./bzImage -initrd ./initramfs.cpio.gz -nographic -append "console=ttyS0"


