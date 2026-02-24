#!/bin/bash

# Setup Environment
export USE_CCACHE=1
export CCACHE_DIR=$HOME/.ccache
export BUILD_NUMBER=$(date +%Y%m%d%H%M)

# Install dependencies if not yet installed
sudo apt update && sudo apt install -y \
    bc bison build-essential ccache curl flex g++-multilib git gnupg gperf \
    lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev \
    libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop python-all python3-venv \
    python3-dev python3-pip

# Install repo tool
if ! command -v repo &>/dev/null; then
    echo "Repo tool not found, installing it"
    mkdir -p $HOME/bin
    curl https://storage.googleapis.com/git-repo-downloads/repo > $HOME/bin/repo
    chmod a+x $HOME/bin/repo
fi

# Setup AOSP source
mkdir -p ~/aosp
cd ~/aosp

# Initialize the repo
repo init -u https://android.googlesource.com/platform/manifest -b lineage-23.1
repo sync -j$(nproc)

# Sync device-specific repository
git clone https://github.com/mt6899-rodin/android_device_xiaomi_rodin -b lineage-23.1 device/xiaomi/rodin
git clone https://github.com/mt6899-rodin/android_vendor_xiaomi_rodin -b lineage-23.1 vendor/xiaomi/rodin
git clone https://github.com/mt6899-rodin/android_kernel_xiaomi_rodin -b lineage-23.1 kernel/xiaomi/rodin

# Setup environment for building
source build/envsetup.sh
lunch lineage_rodin-eng  # Select device configuration

# Build the ROM
make bacon -j$(nproc)  # Build ROM
