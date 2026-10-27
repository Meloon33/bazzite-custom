# Meloon33's Custom Bazzite Gaming OS

Customized [Bazzite](https://bazzite.gg) operating system image built on Fedora Atomic / Bootc, tailored specifically for **AMD Ryzen 7 5800X3D + NVIDIA GeForce RTX 4080 Super** with an out-of-the-box console experience (Steam Gaming Mode).

---

## Hardware & System Profile

* **CPU**: AMD Ryzen 7 5800X3D (8 cores / 16 threads, 3D V-Cache)
* **GPU**: NVIDIA GeForce RTX 4080 Super (16GB GDDR6X, Ada Lovelace)
* **Controllers**: XInput (Xbox Wireless Bluetooth / USB Dongle / 8BitDo / Wired)
* **Primary Target Disk**: External SSD (`Disk 3`, ~250 GB, formerly `F:\`)
* **Shared Game Storage**: `D:\LTSC\Gry` (Internal NVMe Disk 2, Partition 7, NTFS)
* **Base Image**: `ghcr.io/ublue-os/bazzite-deck-nvidia:stable`
* **Container Registry**: `ghcr.io/meloon33/bazzite-custom:latest`

---

## Key Customizations Included

1. **Pure Console Mode (Steam Gaming Mode)**:
   * Boots directly into Gamescope session with Steam Deck UI.
   * Hardware accelerated Wayland web view rendering enabled for smooth UI navigation.
2. **NVIDIA RTX 4080 Super Tuning**:
   * Pre-configured DLSS, DLAA, and Reflex flags (`PROTON_ENABLE_NVAPI=1`, `DXVK_ENABLE_NVAPI=1`).
   * DirectX Raytracing enabled (`VKD3D_CONFIG=dxr11`).
   * G-Sync / VRR support enabled by default.
3. **Safe NTFS Game Library (`D:\LTSC\Gry`)**:
   * Automated mounting at `/mnt/games` via `bazzite-ntfs-mount.service`.
   * **Proton compatdata safety**: Proton Wine prefixes (`compatdata`) are symlinked and written to native SSD storage (`~/.local/share/bazzite-compatdata`), while game assets (`steamapps/common`) remain on NTFS. Prevents prefix corruption and permission failures.
4. **XInput Controller Stack**:
   * Udev rules for Xbox One, Series X|S, Xbox Wireless Dongle (`xone`), and 8BitDo gamepads.
   * Low-latency Bluetooth configuration (`disable_ertm=1`).
5. **Non-Steam Games (Playnite Replacement)**:
   * Built-in `ujust sync-nonsteam-games` powered by BoilR to scan Epic Games, GOG, and Lutris into Steam Game Mode shortcuts with banner art.

---

## Deployment & Setup Guide

### 1. Push Repository to GitHub
Create a new GitHub repository named `bazzite-custom` under your account (`https://github.com/Meloon33/bazzite-custom`), then run:

```bash
git add .
git commit -m "feat: initial custom bazzite configuration"
git remote add origin https://github.com/Meloon33/bazzite-custom.git
git branch -M main
git push -u origin main
```

GitHub Actions will build and publish your container image to:
```
ghcr.io/meloon33/bazzite-custom:latest
```

*(Note: In your GitHub profile settings, ensure Package visibility for `bazzite-custom` is set to Public so your PC can pull updates).*

---

### 2. Install Bazzite to the External SSD (`F:\`, Disk 3)

1. Download the official **Bazzite Deck NVIDIA** ISO from [bazzite.gg](https://bazzite.gg).
2. Flash it to a USB drive using [BalenaEtcher](https://etcher.balena.io/) or [Rufus](https://rufus.ie/) (in DD mode).
3. In Windows, ensure **Fast Startup** is disabled:
   * Open `Control Panel` $\rightarrow$ `Power Options` $\rightarrow$ `Choose what the power buttons do` $\rightarrow$ uncheck `Turn on fast startup`.
4. Reboot and select the USB drive in your motherboard UEFI boot menu (F8 / F11 / F12).
5. In the installer:
   * Select your **External SSD** (`Disk 3`, ~250 GB / JMicron / ExternalSSD).
   * **DO NOT select your internal WD_BLACK SN850X 2TB drive** (`Disk 2`) containing Windows C:, D:, and X:.
   * Proceed with installation.

---

### 3. Rebase to Your Tailored Image

Once booted into Bazzite on your external SSD:
1. Switch to Desktop Mode (Press Power Menu $\rightarrow$ *Switch to Desktop*).
2. Open the terminal (Konsole) and run:
   ```bash
   rpm-ostree rebase ostree-unverified-registry:ghcr.io/meloon33/bazzite-custom:latest
   ```
3. Reboot:
   ```bash
   systemctl reboot
   ```
Your system is now running your customized OS image with persistent atomic updates.

---

### 4. Configure Your Game Library

Open terminal (or run in Desktop Mode):

* **Mount and Link Steam Games from D:\LTSC\Gry:**
  ```bash
  ujust link-steam-ntfs
  ```
  Then in Steam $\rightarrow$ `Settings` $\rightarrow$ `Storage` $\rightarrow$ `Add Drive` $\rightarrow$ select `/mnt/games/LTSC/Gry` (or `/mnt/games`).

* **Sync Non-Steam Games (Epic, GOG, Lutris):**
  ```bash
  ujust sync-nonsteam-games
  ```
  BoilR will launch. Click **Import Games** to pull all games with artwork into Steam Game Mode.

* **Verify RTX 4080 Super Performance:**
  ```bash
  ujust optimize-4080s
  ```

---

## Helpful Commands

| Command | Action |
| :--- | :--- |
| `ujust mount-games-drive` | Mounts `D:\LTSC\Gry` with safe Proton permissions |
| `ujust link-steam-ntfs` | Links Steam library and redirects compatdata to SSD |
| `ujust sync-nonsteam-games` | Syncs Epic/GOG/Lutris games into Steam Big Picture |
| `ujust optimize-4080s` | Displays RTX 4080 Super status and tips |
| `rpm-ostree update` | Updates OS atomically from your GitHub repository |
| `rpm-ostree rollback` | Instantly rolls back to previous OS state if needed |
