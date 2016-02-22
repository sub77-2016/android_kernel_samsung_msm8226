#!/bin/bash
# TWRP kernel for Samsung Galaxy S5 Plus build script by jcadduono
# This build script is for TeamWin Recovery Project only

################### BEFORE STARTING ################
#
# download a working toolchain and extract it somewhere and configure this
# file to point to the toolchain's root directory.
# I highly recommend Christopher83's Linaro GCC 4.9.x Cortex-A15 toolchain.
# Download it here: http://forum.xda-developers.com/showthread.php?t=2098133
#
# once you've set up the config section how you like it, you can simply run
# ./build.sh
#
###################### CONFIG ######################

# root directory of NetHunter kccat6 git repo (default is this script's location)
RDIR=$(pwd)

[ $VER ] || \
# version number
VER=$(cat $RDIR/VERSION)

# directory containing cross-compile arm toolchain
TOOLCHAIN=$HOME/build/toolchain/arm-cortex_a15-linux-gnueabihf-linaro_4.9.4-2015.06

# amount of cpu threads to use in kernel make process
THREADS=5

############## SCARY NO-TOUCHY STUFF ###############

[ "$TARGET" ] || TARGET=twrp
[ "$DEVICE" ] || DEVICE=kccat6

DEFCONFIG="${TARGET}_${DEVICE}_defconfig"

export ARCH=arm
export CROSS_COMPILE=$TOOLCHAIN/bin/arm-eabi-
export LOCALVERSION="$TARGET-$DEVICE-$VER"

KDIR=$RDIR/build/arch/$ARCH/boot

[ -f "$RDIR/arch/$ARCH/configs/$DEFCONFIG" ] || {
	echo "Config $DEFCONFIG not found in $ARCH configs!"
	exit 1
}

CLEAN_BUILD()
{
	echo "Cleaning build..."
	cd $RDIR
	rm -rf build
}

BUILD_KERNEL()
{
	echo "Creating kernel config..."
	cd $RDIR
	mkdir -p build
	make -C $RDIR O=build $DEFCONFIG
	echo "Starting build for $VARIANT..."
	make -C $RDIR O=build -j"$THREADS"
}

BUILD_DTB_IMG()
{
	echo "Generating dtb.img..."
	$RDIR/scripts/dtbTool/dtbTool -o $KDIR/dtb.img $KDIR/ -s 4096
}

CLEAN_BUILD && BUILD_KERNEL && BUILD_DTB_IMG

echo "Finished building ${LOCALVERSION}!"
