#!/bin/bash

workdir=`pwd`

BUILD_SYSTEM=mips64el-linux-gnuabi64
TOOLCHAIN_NAME=loongarch32r-linux-gnusf
INSTALL_ROOT=$workdir/install
TARGET_SYSROOT=$INSTALL_ROOT/sysroot
SRC_DIR=$workdir/src
OBJ_DIR=$workdir/obj
echo "========= la32r_binutils ================"
rm -rf $OBJ_DIR/la32r_binutils_for_build_linux_gnu
mkdir -p $OBJ_DIR/la32r_binutils_for_build_linux_gnu
pushd $OBJ_DIR/la32r_binutils_for_build_linux_gnu
$SRC_DIR/la32r_binutils/configure -target=${TOOLCHAIN_NAME} --prefix=$INSTALL_ROOT --disable-werror --disable-gdb
make -j`nproc`
make install-strip -j`nproc`
popd

echo "========= gcc first ================"
rm -rf $OBJ_DIR/gcc_stage1_for_build_linux_gnu
mkdir $OBJ_DIR/gcc_stage1_for_build_linux_gnu
pushd $OBJ_DIR/gcc_stage1_for_build_linux_gnu
$SRC_DIR/la32r_gcc-8.3.0/configure \
--target=${TOOLCHAIN_NAME} \
--enable-languages=c \
--disable-libmudflap \
--disable-libssp \
--disable-libstdcxx-pch \
--disable-threads \
--disable-shared \
--disable-nls \
--disable-libgomp \
--disable-decimal-float \
--disable-libffi \
--disable-libquadmath \
--disable-libitm \
--disable-libatomic \
--disable-libcc1 \
--disable-emultls \
--enable-tls \
--enable-gnu-indirect-function \
--prefix=$INSTALL_ROOT \
--with-as="$INSTALL_ROOT/bin/${TOOLCHAIN_NAME}-as" \
--with-ar="$INSTALL_ROOT/bin/${TOOLCHAIN_NAME}-ar" \
--with-ld="$INSTALL_ROOT/bin/${TOOLCHAIN_NAME}-ld"
make -j`nproc` V=1 2>&1|tee build.log
make install-strip -j`nproc`
pushd $INSTALL_ROOT/lib/gcc/${TOOLCHAIN_NAME}/8.3.0
popd
popd

echo "========= install kernel header ================"
pushd $SRC_DIR/la32r-Linux
make -j`nproc` ARCH=loongarch INSTALL_HDR_PATH="$TARGET_SYSROOT/usr" headers_install
popd

echo "========= glibc ================"
rm -rf $OBJ_DIR/glibc_for_build_linux_gnu
mkdir $OBJ_DIR/glibc_for_build_linux_gnu
pushd $OBJ_DIR/glibc_for_build_linux_gnu
$SRC_DIR/la32r_glibc-2.28/configure    \
--build=${BUILD_SYSTEM} \
--host=${TOOLCHAIN_NAME} \
--prefix=/usr \
--with-headers="$TARGET_SYSROOT/usr/include" \
--enable-shared \
--disable-profile \
--disable-build-nscd \
--disable-werror \
--enable-obsolete-rpc \
CC="$INSTALL_ROOT/bin/${TOOLCHAIN_NAME}-gcc" \
CFLAGS="-O3" \
CXX="$INSTALL_ROOT/bin/${TOOLCHAIN_NAME}-g++" \
AR="$INSTALL_ROOT/bin/${TOOLCHAIN_NAME}-ar" \
AS="$INSTALL_ROOT/bin/${TOOLCHAIN_NAME}-as"
make -j`nproc` 2>&1|tee build_glibc.log
make install install_root=$TARGET_SYSROOT
popd

echo "========= gcc_second ================"
rm -rf $OBJ_DIR/gcc_stage2_for_build_linux_gnu
mkdir $OBJ_DIR/gcc_stage2_for_build_linux_gnu
pushd $OBJ_DIR/gcc_stage2_for_build_linux_gnu
$SRC_DIR/la32r_gcc-8.3.0/configure \
--target=${TOOLCHAIN_NAME} \
--enable-shared \
--disable-bootstrap \
--disable-emultls \
--enable-tls \
--enable-languages=c,c++,fortran \
--enable-initfini-array \
--enable-gnu-indirect-function \
--prefix=$INSTALL_ROOT \
--with-sysroot=$TARGET_SYSROOT \
--with-build-time-tools=$INSTALL_ROOT/${TOOLCHAIN_NAME}/bin
make -j`nproc` 2>&1|tee build.log
make install-strip -j`nproc`
popd
