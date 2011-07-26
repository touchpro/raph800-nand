#!/bin/sh

KERNEL_PATH=$(cd `dirname $0` && cd .. && pwd)
MODULES_PATH=$KERNEL_PATH/modules
DIRECTORY=$(cd `dirname $0` && pwd)

#-------------------------------------------------------------------------

cd $DIRECTORY
cd ..

rm -Rf $MODULES_PATH/mods
rm -Rf $MODULES_PATH/kernel-modules
rm -f $MODULES_PATH/modules-*.tar.gz

if [ -d "$MODULES_PATH/ti" ] ; then
	cd $MODULES_PATH/ti/sta_dk_4_0_4_32
	make ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PATH KERNEL_DIR=$KERNEL_PATH clean
fi

if [ -d "$MODULES_PATH/compcache-0.5.4" ] ; then
	cd $MODULES_PATH/compcache-0.5.4
	make ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PATH KLIB_BUILD=$KERNEL_PATH KERNEL_BUILD_PATH=$KERNEL_PATH clean
fi

cd $DIRECTORY

rm -f kernel/zImage
rm -f xip/*
rm -f *.NBH

echo "Clean finished."
