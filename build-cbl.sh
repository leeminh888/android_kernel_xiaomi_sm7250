#!/bin/bash
set -euo pipefail

echo "deb http://archive.ubuntu.com/ubuntu eoan main" | sudo tee /etc/apt/sources.list
sudo apt-get update
sudo apt-get -y --no-install-recommends install bison flex libc6 libstdc++6 ccache libfl-dev

export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
##export CCACHE_COMPRESS=1

ccache -M 4G
##ccache --show-stats
mkdir -p $GITHUB_WORKSPACE/TC
cd $GITHUB_WORKSPACE/TC
wget 'https://github.com/kdrag0n/proton-clang-build/releases/download/20200117/proton_clang-11.0.0-20200117.tar.zst'
tar -I zstd -xf proton_clang-11.0.0-20200117.tar.zst
mv proton_clang-11.0.0-20200117/* ./
echo "unarchived!"

cd $GITHUB_WORKSPACE/kernel
args="-j$(nproc --all) \
    O=out \
    ARCH=arm64 \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    DTC_EXT=dtc \
    CROSS_COMPILE=$GITHUB_WORKSPACE/TC/bin/aarch64-linux-gnu- \
    CC=/home/runner/work/android_kernel_xiaomi_sm7250/android_kernel_xiaomi_sm7250/TC/bin/clang "


echo "Make defconfig"
make ${args} picasso_user_defconfig
echo "Make defconfig done, start Make"
make ${args}  CC='ccache /home/runner/work/android_kernel_xiaomi_sm7250/android_kernel_xiaomi_sm7250/TC/bin/clang'
ccache --show-stats
echo "Make Done, packaging now"

cp ./out/arch/arm64/boot/Image.gz-dtb ./AnyKernel3/
cp ./out/arch/arm64/boot/dtbo.img ./AnyKernel3/

#still needed?
cd AnyKernel3/
zip -r9 AnyKernel3.zip *
mv AnyKernel3.zip ../
