#!/bin/sh
#
#This script is modified from th RHOD NAND Project.
#
#-------------------------------------------------------------------------
# Build Script for linux-msm (Android on HTC) kernel and modules
#-------------------------------------------------------------------------
#
# Set the following variables
# KERNEL_PATH -- directory containing the linux-msm kernel source
KERNEL_PATH=$(cd `dirname $0` && cd .. && pwd)
# TOOLCHAIN_PATH -- directory containing the arm toolchain
TOOLCHAIN_PATH=~/prebuilt/linux-x86/toolchain/arm-eabi-4.4.0/bin/arm-eabi-
# MODULES_PATH -- directory containing compcache and tiwlan directories
MODULES_PATH=$KERNEL_PATH/modules
# OUTPUT_PATH -- directory to write the kernel and modules gzip
OUTPUT_PATH=$(cd `dirname $0` && pwd)
# DEVTYPE -- Device type (only used for naming output)
DEVTYPE="RAPH"
#-------------------------------------------------------------------------

DIRECTORY=$(cd `dirname $0` && pwd)
cd $DIRECTORY
cd ..

rm -Rf $MODULES_PATH/mods
rm -Rf $MODULES_PATH/kernel-modules
rm -f $MODULES_PATH/modules-*.tar.gz
cd $KERNEL_PATH
make ARCH=arm htc_msm_raphael_nand_defconfig
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PATH INSTALL_MOD_PATH=$MODULES_PATH/kernel-modules zImage modules modules_install
[ $? -eq 0 ] || fail "Kernel compilation failure"
cd $MODULES_PATH
mkdir $MODULES_PATH/mods

KER_VER="$(cat $KERNEL_PATH/include/config/kernel.release)"

cd kernel-modules
kernmods=$(find -name "*.ko")
for i in $kernmods ; do
	cp $i $MODULES_PATH/mods
done

if [ -d "$MODULES_PATH/ti" ] ; then
	cd $MODULES_PATH/ti/sta_dk_4_0_4_32
	make ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PATH KERNEL_DIR=$KERNEL_PATH
	cp wlan.ko $MODULES_PATH/mods
fi

if [ -d "$MODULES_PATH/compcache-0.5.4" ] ; then
	cd $MODULES_PATH/compcache-0.5.4
	make ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PATH KLIB_BUILD=$KERNEL_PATH KERNEL_BUILD_PATH=$KERNEL_PATH
	cp ramzswap.ko $MODULES_PATH/mods
	cp xvmalloc.ko $MODULES_PATH/mods
fi

cd $MODULES_PATH/mods
tar czf $MODULES_PATH/modules-$KER_VER.tar.gz .
cd ..

if [ ! -d "$OUTPUT_PATH" ] ; then
	echo "Creating $OUTPUT_PATH"
	mkdir -p $OUTPUT_PATH
fi
mkdir $OUTPUT_PATH/output
echo "Outputting files to $OUTPUT_PATH/output"
cp modules-$KER_VER.tar.gz $OUTPUT_PATH/output
#cp $KERNEL_PATH/arch/arm/boot/zImage $OUTPUT_PATH/kernel
echo "Kernel&modules build finished"
