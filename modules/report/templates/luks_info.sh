#!/bin/bash

echo "## LUKS report #############################################################"
echo "# lsblk"
lsblk -f
echo ""
echo "# LUKS version"
cat cryptsetup luksDump /dev/vda2 | grep Version
echo ""
echo "# /etc/default/grub"
cat /etc/default/grub
echo ""
echo "# /etc/dropbear-initramfs/authorized_keys"
cat /etc/dropbear-initramfs/authorized_keys
echo ""
echo "# /etc/dropbear-initramfs/config"
cat /etc/dropbear-initramfs/config
echo ""
echo "# /etc/initramfs-tools/conf.d/ip"
cat /etc/initramfs-tools/conf.d/ip
echo ""
echo "# /usr/share/initramfs-tools/scripts/init-premount/dropbear"
cat /usr/share/initramfs-tools/scripts/init-premount/dropbear
echo ""
echo "# /etc/crypttab"
cat /etc/crypttab
echo ""
echo "# /etc/fstab"
cat /etc/fstab
echo ""


