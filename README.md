First of all - see in all scripts in this sequence:
1.get.sh - download all sources and tools, configure it, fix bugs(kernel), and cross compile
2.install.sh - format your microSD card and install them rootfs, kernel, u-boot and few scripts
3.flash-u-boot.sh - copy u-boot files to microSD card(only if them compiled already)
3.cc-u-boot.sh - download linaro gcc, rkbin, u-boot source and cross compile.
4.cc-kernel.sh - same as cc-u-boot.sh
In releases you find image for microSD card. For instal them use dd. Them contain two partition: 50M boot, 250M root.
If you want resize to all drive, use gdisk for generate backup partition table to end(x, e, w); use fdisk for resize
second partition; resize2fs for resize ext4. Or edit install.sh script before install. Also you can write this img to
internal sd-nand by rkdeveloptool.
