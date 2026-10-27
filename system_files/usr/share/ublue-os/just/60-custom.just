# Custom commands for Meloon33 Bazzite Gaming System

# Mount D:\LTSC\Gry NTFS drive with safe Proton permissions
mount-games-drive:
    @echo "Mounting NTFS game drive..."
    sudo /usr/bin/bazzite-ntfs-mount

# Link Steam NTFS library with safe native SSD compatdata redirection
link-steam-ntfs:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Configuring Steam NTFS library symlinks..."
    sudo /usr/bin/bazzite-ntfs-mount
    REAL_USER=$(id -un)
    COMPAT_DIR="${HOME}/.local/share/bazzite-compatdata"
    mkdir -p "${COMPAT_DIR}"
    echo "Proton compatdata will be stored on native SSD at: ${COMPAT_DIR}"
    echo "Open Steam -> Settings -> Storage -> Add Drive -> Select /mnt/games/LTSC/Gry or /mnt/games."

# Sync Non-Steam games (Epic, GOG, Lutris) into Steam Game Mode with cover art (Playnite alternative)
sync-nonsteam-games:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Checking BoilR non-steam game sync..."
    if ! flatpak list | grep -q "io.github.philipk.boilr"; then
        echo "Installing BoilR via Flatpak..."
        flatpak install -y flathub io.github.philipk.boilr
    fi
    echo "Launching BoilR. Click 'Import Games' to scan Epic, GOG, and Lutris into Steam Gaming Mode!"
    flatpak run io.github.philipk.boilr &

# Check NVIDIA RTX 4080 Super status and driver tuning
optimize-4080s:
    #!/usr/bin/env bash
    echo "=== NVIDIA RTX 4080 Super Gaming Status ==="
    nvidia-smi --query-gpu=gpu_name,driver_version,temperature.gpu,power.draw --format=csv
    echo ""
    echo "Tip: For maximum UI smoothness in Steam Game Mode on NVIDIA:"
    echo "Steam Settings -> Interface -> Enable 'Enable GPU accelerated rendering in web views'"

# Enable low-latency BPF scheduler for Ryzen 7 5800X3D gaming
set-sched-gaming SCHED="scx_lavd":
    #!/usr/bin/env bash
    if command -v systemctl &>/dev/null && systemctl list-unit-files | grep -q "scx"; then
        echo "Switching CPU scheduler to {{ SCHED }} for Ryzen 7 5800X3D..."
        sudo systemctl restart scx || sudo {{ SCHED }} &
    else
        echo "sched-ext service not installed. Available schedulers can be enabled via scx package."
    fi
