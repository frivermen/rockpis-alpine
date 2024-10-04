#!/bin/sh
chmod g+rx,o+rx /

echo "" > /etc/modules

sed -i 's/https/http/' /etc/apk/repositories

apk update

sync && sleep 1

apk add alpine-base alpine-keys openrc apk-tools busybox busybox-suid dbus-libs libblkid libcap libcom_err libc-utils libnl3 libressl libusb libuuid musl openrc zlib dropbear dropbear-scp dropbear-ssh dropbear-dbclient dropbear-openrc e2fsprogs alsa-tools alsa-utils

rc-update add crond sysinit
rc-update add devfs sysinit
rc-update add dmesg sysinit
rc-update add mdev sysinit

rc-update add bootmisc boot
rc-update add hostname boot
rc-update add networking boot
rc-update add sysctl boot
rc-update add syslog boot

rc-update add dropbear default

rc-update add mount-ro shutdown
rc-update add killprocs shutdown
rc-update add savecache shutdown

# enable debug on uart
echo '::respawn:/sbin/getty 1500000 console' >> /etc/inittab

# this prevents lots of tty messages to be logged to syslog
sed -i 's/^tty/# tty/g' /etc/inittab

# mount boot partition
echo '/dev/mmcblk0p1 /boot     vfat    defaults,noatime 0 1' >> /etc/fstab

# changing root password
echo root:1 | chpasswd

echo "rock-pi-s" > /etc/hostname
echo "127.0.0.1     rock-pi-s" >> /etc/hosts

cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
  address 192.168.1.111/24
  gateway 192.168.1.1
EOF

cat << EOF >> /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

exit 0
