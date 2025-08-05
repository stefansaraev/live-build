#!/bin/bash

if [ $# -lt 1 ] ; then
  echo "usage: $0 /dev/sdX"
  exit
fi

if [ ! -e "$1" ] ; then
  echo "meh $1"
  exit
fi

DEVICE=$1

apt-get install syslinux-common syslinux gdisk parted systemd-boot

rm -rf build

mkdir -p build/boot
wget http://boot.test.net.in/ipxe.efi -O build/boot/ipxe.efi
wget http://boot.test.net.in/ipxe.lkrn -O build/boot/ipxe.lkrn

mkdir -p build/boot/modules/bios
cp /usr/lib/syslinux/modules/bios/{libutil,menu}.c32 build/boot/modules/bios

mkdir -p build/EFI/BOOT
cp /usr/lib/systemd/boot/efi/systemd-bootx64.efi build/EFI/BOOT/bootx64.efi

mkdir -p build/live/trixie
wget http://boot.test.net.in/live/trixie/filesystem.squashfs -O build/live/trixie/filesystem.squashfs
wget http://boot.test.net.in/live/trixie/initrd.img -O build/live/trixie/initrd.img
wget http://boot.test.net.in/live/trixie/vmlinuz -O build/live/trixie/vmlinuz

cat > build/syslinux.cfg << _EOF_
PATH /boot/modules/bios
DEFAULT live-trixie
PROMPT 0
TIMEOUT 600
ONTIMEOUT live

UI menu.c32

MENU TITLE BOOT MENU
MENU VSHIFT 5
MENU ROWS 10
MENU TABMSGROW 15
MENU TABMSG Press ENTER to boot or TAB to edit a menu entry
MENU HELPMSGROW 17
MENU HELPMSGENDROW -3
MENU AUTOBOOT BIOS default device boot in # second{,s}...
MENU MARGIN 15

MENU COLOR screen 0 #80ffffff #00000000 std
MENU COLOR border 0 #ffffffff #ee000000 std
MENU COLOR title  0 #ffff3f7f #ee000000 std
MENU COLOR unsel  0 #ffffffff #ee000000 std

LABEL live-trixie
  MENU LABEL ^Live (trixie)
  MENU default
  KERNEL /live/trixie/vmlinuz
  INITRD /live/trixie/initrd.img
  APPEND boot=live components loglevel=3 net.ifnames=0 live-media-path=/live/trixie toram

LABEL net
  MENU LABEL Boot from test.net.in
  KERNEL /boot/ipxe.lkrn
  APPEND dhcp && chain http://boot.test.net.in
_EOF_

mkdir -p build/loader

cat > build/loader/loader.conf << _EOF_
default       01-live-trixie.conf
timeout       10
console-mode  keep
editor        yes
auto-entries  yes
auto-firmware yes
_EOF_

mkdir -p build/loader/entries

cat > build/loader/entries/01-live-trixie.conf << _EOF_
title      ^Live (trixie)
options    boot=live components loglevel=3 net.ifnames=0 live-media-path=/live/trixie toram
linux      /live/trixie/vmlinuz
initrd     /live/trixie/initrd.img
_EOF_

cat > build/loader/entries/10-ipxe.conf << _EOF_
title    Boot from test.net.in (ipxe.efi)
linux    /boot/ipxe.efi
options  dhcp && chain http://boot.test.net.in
_EOF_

sgdisk -g -o ${DEVICE}
sgdisk -o ${DEVICE}
sgdisk -a 1 -n 1:34:1G -c 1:esp -t 1:ef00 -A 1:set:2 -p ${DEVICE}
partprobe ${DEVICE}

sleep 2
mkfs.vfat ${DEVICE}1

dd if=/usr/lib/syslinux/mbr/gptmbr.bin of=${DEVICE} bs=440 count=1

sleep 5
syslinux -i ${DEVICE}1

mkdir -p mount
mount ${DEVICE}1 mount/

cp -a build/* mount/
sync
umount mount/
