# Step-by-Step Guide: Post-Install Setup for Bazzite

This guide walks you through setting up your console-like gaming system on the **External SSD (`Disk 3`)** using your tailored build and connecting your games on **`D:\LTSC\Gry`**.

---

## Phase 1: Pre-Install Checklist in Windows

1. **Disable Fast Startup in Windows (Crucial for NTFS access)**:
   * Press `Win + R`, type `powercfg.cpl` and press Enter.
   * Click **"Choose what the power buttons do"** on the left.
   * Click **"Change settings that are currently unavailable"**.
   * Uncheck **"Turn on fast startup (recommended)"**.
   * Click **Save changes**.
   *(Why: If Fast Startup is on, Windows locks drive D:, and Linux will refuse to write to it).*

2. **Prepare USB Installer**:
   * Download the official **Bazzite Deck NVIDIA** ISO from [bazzite.gg](https://bazzite.gg).
   * Flash the ISO to an empty 8GB+ USB drive using [BalenaEtcher](https://etcher.balena.io/) or Rufus (DD mode).

3. **Backup External SSD**:
   * Ensure any important files on your external SSD (`F:\`) are backed up, as the Bazzite installer will format this drive.

---

## Phase 2: Installation to External SSD

1. Reboot your PC and press your motherboard's boot menu key (`F8`, `F11`, or `F12` depending on motherboard).
2. Select your USB drive in UEFI mode.
3. In the Bazzite installer:
   * Select your language and keyboard layout.
   * On the **Installation Destination** screen:
     * **CRITICAL**: Select **ONLY** your External SSD (~250 GB, JMicron / ExternalSSD).
     * **DO NOT** select your internal 2TB `WD_BLACK SN850X` drive (where Windows C:, D:, and X: reside).
     * Choose **Automatic Partitioning** (or reclaim space if prompted).
   * Click **Begin Installation**.
4. Once completed, reboot and select the External SSD from your boot menu.

---

## Phase 3: First Boot & Desktop Mode

1. Your PC will boot directly into **Steam Gaming Mode** (Steam Deck UI).
2. Complete the initial Steam language and Wi-Fi/Ethernet setup with your Xbox controller.
3. Switch to Desktop Mode:
   * Press the Xbox button (or guide button) on your controller $\rightarrow$ **Power** $\rightarrow$ **Switch to Desktop**.
   * (Alternatively, use mouse to click top-right power icon $\rightarrow$ *Switch to Desktop*).

---

## Phase 4: Run the One-Command Setup Script

Open the terminal (**Konsole**) from the bottom-left application menu:

1. Copy and run the post-install setup script:
   ```bash
   # Download the latest setup script directly from your GitHub repo:
   curl -sSL https://raw.githubusercontent.com/Meloon33/bazzite-custom/main/setup-post-install.sh -o setup-post-install.sh
   chmod +x setup-post-install.sh
   sudo ./setup-post-install.sh
   ```

2. What the script does automatically for you:
   * Finds `D:\LTSC\Gry` and mounts it permanently to `/mnt/games`.
   * Sets up Steam `compatdata` symlinks on your SSD so Proton prefixes never corrupt on NTFS.
   * Optimizes Bluetooth for Xbox wireless controllers (`disable_ertm=1`).
   * Configures NVIDIA RTX 4080 Super flags (DLSS, Reflex, Raytracing).
   * Installs **BoilR** and **Heroic Games Launcher** Flatpaks.

---

## Phase 5: Switch to Your Custom GitHub OS Image

In the same terminal, run:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/meloon33/bazzite-custom:latest
systemctl reboot
```

After rebooting, your system will be running your custom build with built-in systemd auto-mounts, low-latency udev rules, and automatic updates directly from your GitHub repository.

---

## Phase 6: Adding Games to Steam Gaming Mode

### A. Steam Games (from `D:\LTSC\Gry\steamapps`):
1. In Steam $\rightarrow$ Open **Settings** $\rightarrow$ **Storage**.
2. Click **Add Drive** (or the drive dropdown).
3. Navigate to: `/mnt/games/LTSC/Gry` (or `/mnt/games`).
4. Select the folder. Steam will instantly detect all installed Steam games without re-downloading.

### B. Epic Games & GOG:
1. In Desktop Mode, open **Heroic Games Launcher**.
2. Log into Epic Games / GOG.
3. For each installed game, click **Add Game** / **Import Existing Game** and select the game's folder inside `/mnt/games/LTSC/Gry/Epic Games` or `/mnt/games/LTSC/Gry/GOG`.
4. Heroic will verify files in seconds.

### C. Sync Everything into Steam Gaming Mode (Playnite Alternative):
1. Open **BoilR** from the application menu.
2. Click the **Import Games** button.
3. BoilR will scan Heroic, Lutris, and standalone games, grab banner artwork, and add them directly into your Steam Gaming Mode library.
4. Click the desktop shortcut **"Return to Gaming Mode"**.

---

## Phase 7: NVIDIA RTX 4080 Super Console UI Smoothness Tip

For the smoothest 120Hz/60Hz navigation in the console UI:
1. In Steam Game Mode, go to **Settings** $\rightarrow$ **Interface**.
2. Ensure **"Enable GPU accelerated rendering in web views (requires restart)"** is turned **ON**.
3. Restart Steam when prompted.

---

## Daily Usage Cheat Sheet

| Goal | Action |
| :--- | :--- |
| **Boot Bazzite** | Turn on PC $\rightarrow$ tap boot key (F8/F11/F12) $\rightarrow$ select External SSD |
| **Boot Windows** | Turn on PC without tapping boot key (default boot) |
| **Sync new non-Steam games** | Desktop Mode $\rightarrow$ run `ujust sync-nonsteam-games` |
| **Check GPU status** | Run `ujust optimize-4080s` |
| **Update OS** | Run `rpm-ostree update` (or update via Steam Game Mode system settings) |
| **Undo any OS update** | Run `rpm-ostree rollback` |
