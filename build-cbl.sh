#!/bin/bash
set -euo pipefail

echo "deb http://archive.ubuntu.com/ubuntu eoan main" | sudo tee /etc/apt/sources.list
sudo apt-get update
sudo apt-get -y --no-install-recommends install bison flex libc6 libstdc++6 ccache libfl-dev

git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86  --depth=1 TC

mkdir -p $GITHUB_WORKSPACE/gcc
cd $GITHUB_WORKSPACE/gcc
wget https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/a9b70fc1b59747d1334677e539b2ef4c752a59a1.tar.gz -O gcc.tar.gz
tar -xf gcc.tar.gz

echo "unarchived!"


cd $GITHUB_WORKSPACE/kernel
args="-j$(nproc --all) \
    O=out \
    ARCH=arm64 \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    DTC_EXT=dtc \
    CROSS_COMPILE=$GITHUB_WORKSPACE/gcc/bin/aarch64-linux-android- \
    CC=$GITHUB_WORKSPACE/TC/clang-r383902/bin/clang"

echo "Make defconfig"
make ${args} picasso_user_defconfig
echo "Make defconfig done, start Make"
make ${args}
