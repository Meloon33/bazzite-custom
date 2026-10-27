#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Meloon33 Bazzite Post-Install Automation Script
# Sets up NTFS games drive, Proton compatdata, BoilR, Heroic, and GPU tuning.
# ==============================================================================

if [ "$(id -u)" -ne 0 ]; then
    echo "Must run with sudo: sudo ./setup-post-install.sh"
    exit 1
fi

REAL_USER="${SUDO_USER:-$(id -un 1000 2>/dev/null || echo "bazzite")}"
REAL_UID=$(id -u "${REAL_USER}")
REAL_GID=$(id -g "${REAL_USER}")
USER_HOME=$(eval echo "~${REAL_USER}")

echo "=========================================================="
echo " Starting Meloon33 Bazzite Setup for user: ${REAL_USER}"
echo "=========================================================="

# ------------------------------------------------------------------------------
# 1. Detect and Automount D:\LTSC\Gry (NTFS Partition)
# ------------------------------------------------------------------------------
echo "[1/6] Scanning disks for NTFS games library (D:\LTSC\Gry)..."

MOUNT_POINT="/mnt/games"
mkdir -p "${MOUNT_POINT}"

TARGET_DEV=""
for dev in $(lsblk -lno PATH,FSTYPE | awk '$2 ~ /ntfs/ {print $1}'); do
    TMP_PROBE="/tmp/probe_$$"
    mkdir -p "${TMP_PROBE}"
    if mount -t ntfs3 -o ro "${dev}" "${TMP_PROBE}" 2>/dev/null || mount -t ntfs-3g -o ro "${dev}" "${TMP_PROBE}" 2>/dev/null; then
        if [ -d "${TMP_PROBE}/LTSC/Gry" ] || [ -d "${TMP_PROBE}/steamapps" ]; then
            TARGET_DEV="${dev}"
            umount "${TMP_PROBE}" || true
            rmdir "${TMP_PROBE}" || true
            break
        fi
        umount "${TMP_PROBE}" || true
    fi
    rmdir "${TMP_PROBE}" || true
done

if [ -n "${TARGET_DEV}" ]; then
    UUID=$(lsblk -no UUID "${TARGET_DEV}" | head -n1)
    echo "Found game drive: ${TARGET_DEV} (UUID=${UUID})"

    # Mount now if not mounted
    if ! grep -qs "${MOUNT_POINT}" /proc/mounts; then
        if ! mount -t ntfs3 -o "uid=${REAL_UID},gid=${REAL_GID},umask=0022,noatime,iocharset=utf8" "${TARGET_DEV}" "${MOUNT_POINT}" 2>/dev/null; then
            mount -t ntfs-3g -o "uid=${REAL_UID},gid=${REAL_GID},umask=0022,windows_names,big_writes,nofail" "${TARGET_DEV}" "${MOUNT_POINT}"
        fi
    fi

    # Persistent fstab entry
    FSTAB_LINE="UUID=${UUID} ${MOUNT_POINT} ntfs3 uid=${REAL_UID},gid=${REAL_GID},umask=0022,noatime,iocharset=utf8,nofail 0 0"
    if ! grep -q "${UUID}" /etc/fstab; then
        echo "Adding permanent mount to /etc/fstab..."
        echo "${FSTAB_LINE}" >> /etc/fstab
    fi
    echo "NTFS drive mounted successfully at ${MOUNT_POINT}."
else
    echo "WARNING: Could not find NTFS partition with LTSC/Gry. Check if Windows Fast Startup is disabled."
fi

# ------------------------------------------------------------------------------
# 2. Redirect Steam Proton compatdata to SSD (Prevents NTFS corruption)
# ------------------------------------------------------------------------------
echo "[2/6] Configuring Proton compatdata redirection..."

SSD_COMPAT_DIR="${USER_HOME}/.local/share/bazzite-compatdata"
mkdir -p "${SSD_COMPAT_DIR}"
chown -R "${REAL_UID}:${REAL_GID}" "${SSD_COMPAT_DIR}"

GAMES_DIR="${MOUNT_POINT}/LTSC/Gry"
STEAMAPPS_DIR=""
if [ -d "${GAMES_DIR}/steamapps" ]; then
    STEAMAPPS_DIR="${GAMES_DIR}/steamapps"
elif [ -d "${MOUNT_POINT}/steamapps" ]; then
    STEAMAPPS_DIR="${MOUNT_POINT}/steamapps"
fi

if [ -n "${STEAMAPPS_DIR}" ]; then
    if [ -d "${STEAMAPPS_DIR}/compatdata" ] && [ ! -L "${STEAMAPPS_DIR}/compatdata" ]; then
        mv "${STEAMAPPS_DIR}/compatdata" "${STEAMAPPS_DIR}/compatdata.bak.$(date +%s)"
    fi
    if [ ! -L "${STEAMAPPS_DIR}/compatdata" ]; then
        ln -sf "${SSD_COMPAT_DIR}" "${STEAMAPPS_DIR}/compatdata"
        echo "Linked ${STEAMAPPS_DIR}/compatdata -> ${SSD_COMPAT_DIR}"
    fi
fi

# ------------------------------------------------------------------------------
# 3. Controller Stack Optimization (XInput & Bluetooth)
# ------------------------------------------------------------------------------
echo "[3/6] Configuring XInput and Xbox Bluetooth low-latency..."

mkdir -p /etc/modprobe.d
cat << 'EOF' > /etc/modprobe.d/xbox_bt.conf
options bluetooth disable_ertm=1
EOF

# Reload bluetooth module if active
rmmod btusb 2>/dev/null || true
modprobe btusb 2>/dev/null || true

# ------------------------------------------------------------------------------
# 4. NVIDIA RTX 4080 Super Gaming Flags
# ------------------------------------------------------------------------------
echo "[4/6] Setting NVIDIA gaming environment variables..."

mkdir -p /etc/environment.d
cat << 'EOF' > /etc/environment.d/10-nvidia-gaming.conf
PROTON_ENABLE_NVAPI=1
DXVK_ENABLE_NVAPI=1
VKD3D_CONFIG=dxr11
__GL_VRR_ALLOWED=1
__GL_GSYNC_ALLOWED=1
LIBVA_DRIVER_NAME=nvidia
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
EOF

# ------------------------------------------------------------------------------
# 5. Install Playnite Alternatives (BoilR & Heroic Games Launcher)
# ------------------------------------------------------------------------------
echo "[5/6] Installing BoilR and Heroic Games Launcher (Flatpaks)..."

sudo -u "${REAL_USER}" flatpak install -y flathub \
    io.github.philipk.boilr \
    com.heroicgameslauncher.hgl \
    net.davidotek.pupgui2 || true

# ------------------------------------------------------------------------------
# 6. Optional Rebase to Custom Container Image
# ------------------------------------------------------------------------------
echo "[6/6] Checking custom image rebase..."
CUSTOM_IMAGE="ostree-unverified-registry:ghcr.io/meloon33/bazzite-custom:latest"

echo ""
echo "=========================================================="
echo " Setup complete!"
echo " Next actions:"
echo " 1. In Steam Game Mode -> Settings -> Storage -> Add Drive -> Select ${MOUNT_POINT}/LTSC/Gry"
echo " 2. In Desktop Mode, open Heroic -> point to ${GAMES_DIR}/Epic Games and ${GAMES_DIR}/GOG"
echo " 3. Run BoilR from Application menu to import all games into Steam Gaming Mode"
echo ""
echo " To switch to your custom GitHub image right now, run:"
echo "   rpm-ostree rebase ${CUSTOM_IMAGE}"
echo "   systemctl reboot"
echo "=========================================================="
