#!/bin/bash

set -ouex pipefail

# Copy system_files overlay to root filesystem
cp -avf "/ctx/system_files"/. /

# Ensure executable permissions on helper scripts
chmod +x /usr/bin/bazzite-ntfs-mount

### Install packages for NTFS and gaming support
dnf5 install -y \
    ntfs-3g \
    attr \
    fuse-overlayfs \
    vulkan-tools

### Enable custom system services
systemctl enable bazzite-ntfs-mount.service

echo "Build script completed successfully."
