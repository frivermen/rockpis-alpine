#!/bin/sh
BASE_DIR=$(pwd)

OUT_DIR=$BASE_DIR/out
if [ ! -e $OUT_DIR ]; then
  mkdir $OUT_DIR
fi

TOOLCHAIN_DIR=$BASE_DIR/toolchain
if [ ! -e $TOOLCHAIN_DIR ]; then
  mkdir $TOOLCHAIN_DIR
fi

DOWNLOADS_DIR=$BASE_DIR/downloads
if [ ! -e $DOWNLOADS_DIR ]; then
  mkdir $DOWNLOADS_DIR
fi

GCC_LINARO_DIR=$TOOLCHAIN_DIR/gcc-linaro-7.5.0-2019.12-i686_aarch64-linux-gnu
if [ ! -e $GCC_LINARO_DIR ]; then
  wget -P $DOWNLOADS_DIR http://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-i686_aarch64-linux-gnu.tar.xz
  tar xf $DOWNLOADS_DIR/gcc-linaro-7.5.0-2019.12-i686_aarch64-linux-gnu.tar.xz -C $TOOLCHAIN_DIR
fi

RKBIN_DIR=$TOOLCHAIN_DIR/rkbin-develop-v2024.03
if [ ! -e $RKBIN_DIR ]; then
  wget -O $DOWNLOADS_DIR/rkbin.zip https://github.com/radxa/rkbin/archive/refs/heads/develop-v2024.03.zip
  unzip -qq $DOWNLOADS_DIR/rkbin.zip -d $TOOLCHAIN_DIR
fi

if [ ! -e $1 ]; then
  echo "u-boot sources not found"
  echo "for download mainline u-boot-v2024.07:"
  echo "wget -P $DOWNLOADS_DIR https://github.com/u-boot/u-boot/archive/refs/tags/v2024.07.tar.gz"
  echo "tar xf $DOWNLOADS_DIR/v2024.07.tar.gz"
  exit
fi

export ARCH=arm64
export CROSS_COMPILE=$GCC_LINARO_DIR/bin/aarch64-linux-gnu-
export BL31=$RKBIN_DIR/bin/rk33/rk3308_bl31_v2.26.elf
export ROCKCHIP_TPL=$RKBIN_DIR/bin/rk33/rk3308_ddr_589MHz_uart0_m0_v2.06.bin

if [ ! -z "$1" ]; then
  cd $1
else 
  echo "usage: $0 some_source make_argument"
  exit
fi

make -j$[($(nproc)*2)] $2
if [ $? -eq 0 ]; then
  $RKBIN_DIR/tools/loaderimage --pack --uboot u-boot-dtb.bin uboot.img 0x600000 --size 1024 1
  $RKBIN_DIR/tools/mkimage -n rk3308 -T rksd -d $ROCKCHIP_TPL idbloader.img
  cat $RKBIN_DIR/bin/rk33/rk3308_miniloader_v1.39.bin >> idbloader.img
  cat >trust.ini <<EOF
[VERSION]
MAJOR=1
MINOR=0
[BL30_OPTION]
SEC=0
[BL31_OPTION]
SEC=1
PATH=$BL31
ADDR=0x00010000
[BL32_OPTION]
SEC=0
[BL33_OPTION]
SEC=0
[OUTPUT]
PATH=trust.img
EOF
  $RKBIN_DIR/tools/trust_merger --size 1024 1 trust.ini
  if [ ! -e $OUT_DIR/$1 ]; then
    mkdir $OUT_DIR/$1
  fi
  if [ -f uboot.img ]; then
    cp uboot.img $OUT_DIR/$1/
    cp trust.img $OUT_DIR/$1/
    cp idbloader.img $OUT_DIR/$1/
    echo "u-boot in out"
  fi
fi

speaker-test -t sine -f 2500 -l 1 >/dev/null

