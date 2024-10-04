#!/bin/sh
if [ -ne $1 ]; then
  echo "usage: $0 u-boot_files_dir/ /dev/sdX"
  exit
fi
dd if=$1/idbloader.img of=$2 seek=64    conv=notrunc
dd if=$1/uboot.img     of=$2 seek=16384 conv=notrunc
dd if=$1/trust.img     of=$2 seek=24576 conv=notrunc
