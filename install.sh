#!/bin/sh
sfdisk $1 <<\EOF
label: gpt
unit: sectors
first-lba: 2048
part1 : start=32768, size=50M, name=boot, bootable
part2 : size=250M, name=rootfs
EOF
sync
mkfs.vfat ${1}1
mkfs.ext4 ${1}2
if [ ! -e mnt/ ]; then
  mkdir mnt
fi
rm -rf mnt/*
mount "${1}2" mnt/
mkdir mnt/boot
mount "${1}1" mnt/boot/
cp -rp alpine-3.20/* mnt/
cp -rp out/kernel-stable-4.4-rockpis/* mnt/boot/
cp -rp overlay_rootfs/* mnt/
chmod 755 mnt/root/start_chroot.sh
chmod 755 mnt/root/init_setup.sh
umount mnt/boot
umount mnt

./flash-u-boot.sh u-boot-2024.07/ $1

echo "
  base rootfs, u-boot, kernel installed
  now you need to chroot to this microsd card
  from arm64 host pc

  mount /dev/sda2 /mnt/
  mount /dev/sda1 /mnt/boot/
  /mnt/root/start_chroot.sh /mnt
  /root/init_setup.sh

  after this you can use microsd card 
  with alpine linux on your rock pi s
"

