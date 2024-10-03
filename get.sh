#!/bin/sh
wget -P downloads https://github.com/radxa/kernel/archive/refs/heads/stable-4.4-rockpis.zip
unzip -qq downloads/stable-4.4-rockpis.zip -d .
./cc-kernel.sh kernel-stable-4.4-rockpis/ rk3308_linux_defconfig
cat <<EOF >> kernel-stable-4.4-rockpis/arch/arm64/boot/dts/rockchip/rk3308-rock-pi-s.dts
&uart0 {
status = "okay";
};
EOF
sed -i 's/YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel-stable-4.4-rockpis/scripts/dtc/dtc-lexer.lex.c
sed -i 's/YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel-stable-4.4-rockpis/scripts/dtc/dtc-lexer.lex.c_shipped
sed -i 's/CONFIG_USB_STORAGE=m/CONFIG_USB_STORAGE=y/' kernel-stable-4.4-rockpis/.config
./cc-kernel.sh kernel-stable-4.4-rockpis/

wget -P downloads https://github.com/u-boot/u-boot/archive/refs/tags/v2024.07.tar.gz
tar xf downloads/v2024.07.tar.gz
./cc-u-boot.sh u-boot-2024.07/ rock-pi-s-rk3308_defconfig
./cc-u-boot.sh u-boot-2024.07/

mkdir alpine-3.20
wget -P downloads https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/alpine-minirootfs-3.20.0-aarch64.tar.gz
tar xf downloads/alpine-minirootfs-3.20.0-aarch64.tar.gz -C alpine-3.20

echo "
    now start: install.sh /dev/sdX
"
