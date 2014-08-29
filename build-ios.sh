#!/bin/sh -x

set -e

source ./setting.sh

DEV_ROOT=`xcode-select -p`

OPTIONS="\
--enable-fixed-point \
--enable-static \
--disable-shared "

cd opus

for ARCH in $ARCHS; do
    DIST_DIR=../build/$ARCH
    mkdir -p $DIST_DIR
    PLATFORM=iPhoneOS
    HOST=${ARCH}-apple-darwin

    case $ARCH in
        armv7)
            EXTRA_FLAGS="--with-pic"
            EXTRA_CFLAGS=""
            ;;
        armv7s)
            EXTRA_FLAGS="--with-pic"
            EXTRA_CFLAGS=""
            ;;
        arm64)
            EXTRA_FLAGS="--with-pic"
            EXTRA_CFLAGS=""
            HOST=aarch64-apple-darwin
            ;;
        i386)
            EXTRA_FLAGS="--with-pic"
            EXTRA_CFLAGS="-mios-simulator-version-min=6.0"
            PLATFORM=iPhoneSimulator
            ;;
        *)
            echo "Unsupported architecture ${ARCH}"
            exit 1
            ;;
    esac

    SDK_ROOT=$DEV_ROOT/Platforms/$PLATFORM.platform/Developer/SDKs/$PLATFORM$IOS_SDK_VERSION.sdk
    OPTIONS=$OPTIONS" --prefix="
    OPTIONS=$OPTIONS" --with-sysroot=$SDK_ROOT"

	./autogen.sh

	CFLAGS="-g -O3 -pipe -arch ${ARCH} \
		-isysroot ${SDK_ROOT} \
        -I${SDK_ROOT}/usr/include \
		${EXTRA_CFLAGS}"
    LDFLAGS="-arch ${ARCH} \
		-isysroot ${SDK_ROOT} \
        -L${SDK_ROOT}/usr/lib" 

	export CFLAGS
	export LDFLAGS

    export CXXCPP=`xcrun -find -sdk iphoneos clang++`
    export CPP=`$CXXCPP`
    export CXX=`xcrun -find -sdk iphoneos clang++`
    export CC=`xcrun -find -sdk iphoneos clang`
    export LD=`xcrun -find -sdk iphoneos ld`
    export AR=`xcrun -find -sdk iphoneos ar`
    export AS=`xcrun -find -sdk iphoneos as`
    export NM=`xcrun -find -sdk iphoneos nm`
    export RANLIB=`xcrun -find -sdk iphoneos ranlib`
    export STRIP=`xcrun -find -sdk iphoneos strip`

    ./configure \
    	--prefix=`pwd`/$DIST_DIR \
		--host=${HOST} \
		--with-sysroot=${SDK_ROOT} \
		--enable-static=yes \
		--enable-shared=no \
	    --disable-doc \
		${EXTRA_FLAGS}

    make clean
    make 
    make install
done

# lipo
INPUT=
for ARCH in $ARCHS; do
    INPUT="${INPUT} ../build/$ARCH/lib/libopus.a"
done


mkdir -p ../build/lipo/lib
lipo -create $INPUT -output ../build/lipo/lib/libopus.a

# header
cp -rf ../build/$ARCH/include ../build/lipo/
