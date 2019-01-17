#!/bin/bash

#install fixed linux-kernel version
apt-get install linux-image-4.9.0-8-amd64 -y

#update extlinux.conf
echo "default linux
timeout 1
label linux
kernel /boot/vmlinuz-4.9.0-8-amd64
append initrd=/boot/initrd.img-4.9.0-8-amd64 root=/dev/vda1 console=tty0 console=ttyS0,115200 ro quiet" > /boot/extlinux/extlinux.conf

#update extlinux
extlinux --update /boot/extlinux
