#!/usr/bin/env bash
# Script to install osxcross with SDK

[ "$OSXCROSS_URL" ] || OSXCROSS_URL="https://github.com/tpoechtrager/osxcross/archive/be2b79f444aa0b43b8695a4fb7b920bf49ecc01c.tar.gz"
[ "$OSXCROSS_SHA256" ] || OSXCROSS_SHA256=41f24fa591a1968a178aa2374323485466e99fff7660e88901eda6add5a1e7f0
[ "$SDK_URL" ] || SDK_URL="https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX11.3.sdk.tar.xz"
[ "$SDK_SHA256" ] || SDK_SHA256=cd4f08a75577145b8f05245a2975f7c81401d75e9535dcffbb879ee1deefcbf4

root_dir=$PWD
[ "$root_dir" != '/' ] || root_dir=""

# Init the package system
sudo apt update

echo
echo '--> Save the original installed packages list'
echo

sudo dpkg --get-selections | cut -f 1 > /tmp/packages_orig.lst

echo
echo '--> Install the required packages to install osxcross'
echo

sudo apt install -y curl ca-certificates clang llvm-dev libxml2-dev uuid-dev libssl-dev cpio libbz2-dev make patch git zlib1g-dev

echo
echo '--> Download & install the osxcross and sdk'
echo

mkdir /tmp/osxcross
cd /tmp/osxcross

echo "$OSXCROSS_SHA256 -" > sum.txt && curl -fLs "$OSXCROSS_URL" | tee /tmp/osxcross.tar.gz | sha256sum -c sum.txt
tar xf /tmp/osxcross.tar.gz --strip-components=1
echo "$SDK_SHA256 -" > sum.txt && curl -fLs "$SDK_URL" | tee /tmp/osxcross/tarballs/$(basename "$SDK_URL") | sha256sum -c sum.txt

# Build and place the osxcross
export OUT_DIR=/opt/osxcross
UNATTENDED=1 TARGET_DIR=$OUT_DIR ./build.sh

# Create helper files
mkdir -p /usr/local/bin
cat - <<EOF > /usr/local/bin/qt-cmake
#!/bin/sh
set -e

# Set arch to "x86_64" or "aarch64" to build it
[ "\$BUILD_ARCH" ] || BUILD_ARCH=x86_64

eval "\$($OUT_DIR/bin/\$BUILD_ARCH-apple-*-osxcross-conf)"
export OSXCROSS_HOST="\$BUILD_ARCH-apple-\$OSXCROSS_TARGET"
export OSXCROSS_TOOLCHAIN_FILE="\$OSXCROSS_TARGET_DIR"/toolchain.cmake
export CMAKE_TOOLCHAIN_FILE=\$QT_MACOS/lib/cmake/Qt6/qt.toolchain.cmake

exec cmake -DQT_CHAINLOAD_TOOLCHAIN_FILE=\$OSXCROSS_TOOLCHAIN_FILE "\$@"
EOF

sudo chmod +x /usr/local/bin/*

# Required tools for macdeployqt, they will work for both architectures
sudo ln -s $OUT_DIR/bin/x86_64-apple-*-otool /usr/local/bin/otool
sudo ln -s $OUT_DIR/bin/x86_64-apple-*-install_name_tool /usr/local/bin/install_name_tool
sudo ln -s $OUT_DIR/bin/x86_64-apple-*-strip /usr/local/bin/strip

echo
echo '--> Restore the packages list to the original state'
echo

sudo dpkg --get-selections | cut -f 1 > /tmp/packages_curr.lst
grep -Fxv -f /tmp/packages_orig.lst /tmp/packages_curr.lst | xargs apt remove -y --purge

# Complete the cleaning

sudo apt -qq clean
sudo rm -rf /var/lib/apt/lists/* /tmp/osxcross*
