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

if [ ! -e $1 ]; then
  echo "linux sources not found"
  echo "for download vendor linux-4.4:"
  echo "wget -P $DOWNLOADS_DIR https://github.com/radxa/kernel/archive/refs/heads/stable-4.4-rockpis.zip"
  echo "unzip -qq $DOWNLOADS_DIR/stable-4.4-rockpis.zip -d $BASE_DIR"
  exit
fi

IMAGE_PATH=arch/arm64/boot/Image
DTB_PATH=arch/arm64/boot/dts/rockchip/rk3308-rock-pi-s.dtb

export ARCH=arm64
export CROSS_COMPILE=$GCC_LINARO_DIR/bin/aarch64-linux-gnu-
export INSTALL_MOD_PATH=$OUT_DIR/$1
export INSTALL_HDR_PATH=$OUT_DIR/$1

if [ ! -z "$1" ]; then
  cd $1
else 
  echo "usage: $0 some_source make_argument"
  exit
fi
if [ ! -e $OUT_DIR/$1 ]; then
  mkdir $OUT_DIR/$1
fi
make -j$[($(nproc)*2)] $2
if [ $? -eq 0 ]; then
  if [ -f $IMAGE_PATH ]; then
    cp $IMAGE_PATH $OUT_DIR/$1/
    echo "Image in out"
  fi
  if [ -f $DTB_PATH ]; then
    cp $DTB_PATH $OUT_DIR/$1/
    echo "dtb in out"
  fi
fi

speaker-test -t sine -f 2500 -l 1 >/dev/null

