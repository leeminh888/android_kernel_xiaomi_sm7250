#!/bin/bash
set -euo pipefail

echo "deb http://archive.ubuntu.com/ubuntu eoan main" | sudo tee /etc/apt/sources.list
sudo apt-get update
sudo apt-get -y --no-install-recommends install bison flex libc6 libstdc++6 ccache libfl-dev
sudo apt install -y gcc g++ python make  bc bison build-essential ccache curl flex g++-multilib gcc-multilib \
    git gnupg imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev  \
    libssl-dev  libxml2 libxml2-utils rsync  squashfs-tools xsltproc zip zlib1g-dev \
    unzip language-pack-zh-hans
mkdir $GITHUB_WORKSPACE/ccache
#export CCACHE_DIR=$GITHUB_WORKSPACE/ccache
#export USE_CCACHE=1



echo $GITHUB_WORKSPACE

echo $(ldd --version)


mkdir $GITHUB_WORKSPACE/TC
cd $GITHUB_WORKSPACE/TC
wget 'https://github.com/kdrag0n/proton-clang-build/releases/download/20200117/proton_clang-11.0.0-20200117.tar.zst'
tar -I zstd -xf proton_clang-11.0.0-20200117.tar.zst
mv proton_clang-11.0.0-20200117/* ./

#wget 'https://dl.akr-developers.com/s/CBL/LiuNian_clang-20200415.tar.zst'
#tar -I zstd -xf LiuNian_clang-20200415.tar.zst
echo "unarchived!"

#export PATH=$GITHUB_WORKSPACE/TC/bin:$PATH

cd $GITHUB_WORKSPACE/kernel
args="-j$(nproc --all) \
    O=out \
    ARCH=arm64 \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE=$GITHUB_WORKSPACE/TC/bin/aarch64-linux-gnu- \
    CC=$GITHUB_WORKSPACE/TC/bin/clang"

echo "Make defconfig"
make ${args} picasso_user_defconfig
echo "Make"
make ${args}
