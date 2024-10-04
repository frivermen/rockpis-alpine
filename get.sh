#!/bin/sh
BASE_DIR=$(pwd)

DOWNLOADS_DIR=$BASE_DIR/downloads
if [ ! -e $DOWNLOADS_DIR ]; then
  mkdir $DOWNLOADS_DIR
fi

if [ ! -f $DOWNLOADS_DIR/stable-4.4-rockpis.zip ]; then
    wget -P downloads https://github.com/radxa/kernel/archive/refs/heads/stable-4.4-rockpis.zip
fi
if [ ! -e kernel-stable-4.4-rockpis ]; then
    unzip -qq downloads/stable-4.4-rockpis.zip -d .
fi
if [ ! -f kernel-stable-4.4-rockpis/.config ]; then
    ./cc-kernel.sh kernel-stable-4.4-rockpis/ rk3308_linux_defconfig
    cat <<EOF >> kernel-stable-4.4-rockpis/arch/arm64/boot/dts/rockchip/rk3308-rock-pi-s.dts
    &uart0 {
    status = "okay";
    };
    EOF
    sed -i 's/YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel-stable-4.4-rockpis/scripts/dtc/dtc-lexer.lex.c
    sed -i 's/YYLTYPE yylloc;/extern YYLTYPE yylloc;/' kernel-stable-4.4-rockpis/scripts/dtc/dtc-lexer.lex.c_shipped
    sed -i 's/CONFIG_USB_STORAGE=m/CONFIG_USB_STORAGE=y/' kernel-stable-4.4-rockpis/.config
fi
./cc-kernel.sh kernel-stable-4.4-rockpis/

if [ ! -f $DOWNLOADS_DIR/v2024.07.tar.gz ]; then
    wget -P downloads https://github.com/u-boot/u-boot/archive/refs/tags/v2024.07.tar.gz
fi
if [ ! -e u-boot-2024.07 ]; then
    tar xf downloads/v2024.07.tar.gz
fi
if [ ! -f u-boot-2024.07/.config ]; then
    ./cc-u-boot.sh u-boot-2024.07/ rock-pi-s-rk3308_defconfig
fi
./cc-u-boot.sh u-boot-2024.07/

if [ ! -f $DOWNLOADS_DIR/alpine-minirootfs-3.20.0-aarch64.tar.gz ]; then
    wget -P downloads https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/alpine-minirootfs-3.20.0-aarch64.tar.gz
fi
if [ ! -e alpine-3.20 ]; then
    mkdir alpine-3.20
    tar xf downloads/alpine-minirootfs-3.20.0-aarch64.tar.gz -C alpine-3.20
fi

echo "
    now start: install.sh /dev/sdX
"
