# PRE-INSTALL.md

This guide covers the complete Arch Linux installation process **before** running the automated post-installation scripts in this repository.

## Prerequisites

- UEFI system
- Internet connection
- USB installation media with Arch Linux ISO

---

## 1. Pre-Installation Setup

### 1.5 Set Console Keyboard Layout and Font

```bash
# List available keymaps
localectl list-keymaps

# Load UK keyboard layout
loadkeys uk
```

### 1.6 Verify Boot Mode

```bash
# Verify UEFI boot mode (should return 64)
cat /sys/firmware/efi/fw_platform_size
```

### 1.7 Connect to the Internet

```bash
# Check network interfaces
ip link

# Connect to WiFi using iwctl
iwctl
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect Gigaclear_2109  # Replace with your SSID
exit

# Verify connection
ip a
ping archlinux.org
iwctl station wlan0 show
```

### 1.8 Update System Clock

```bash
timedatectl
```

### 1.9 Partition the Disks

```bash
# List available disks
fdisk -l

# Start partitioning (replace /dev/nvme0n1 with your disk)
fdisk /dev/nvme0n1
```

**Partitioning commands in fdisk:**

1. **Create GPT partition table:**
   - `g`

2. **Create EFI partition (2GB):**
   - `n` → `1` → `[Enter]` → `+2G` → `y`
   - `t` → `1` → `1` (EFI System)

3. **Create Swap partition (8GB):**
   - `n` → `2` → `[Enter]` → `+8G` → `y`
   - `t` → `2` → `19` (Linux swap)

4. **Create Root partition (remaining space):**
   - `n` → `3` → `[Enter]` → `[Enter]` → `y`

5. **Write changes:**
   - `w`

**Format and mount partitions:**

```bash
# Verify partitions
fdisk -l /dev/nvme0n1

# Format partitions
mkfs.ext4 /dev/nvme0n1p3     # Root partition
mkswap /dev/nvme0n1p2        # Swap partition
mkfs.fat -F 32 /dev/nvme0n1p1  # EFI partition

# Mount partitions
mount /dev/nvme0n1p3 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
swapon /dev/nvme0n1p2
```

---

## 2. Installation

### 2.1 Select Mirrors

```bash
# Optimize mirror list (optional)
nano /etc/pacman.d/mirrorlist
```

**Alternative mirror optimization:**

```bash
rm -rf /var/cache/pacman/pkg/*
pacman -Sy
pacman -S reflector
reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
```

### 2.2 Install Essential Packages

**Base system:**

```bash
pacstrap -K /mnt base linux linux-firmware
```

**Additional essential packages (single command):**

```bash
pacstrap /mnt amd-ucode e2fsprogs mtools dosfstools sof-firmware iwd dhcpcd nano man-db man-pages texinfo nvidia nvidia-utils
```

**Packages you should also install:**

```bash
pacstrap /mnt sudo bluez-utils firefox git xkeyboard-config kbd
```

---

## 3. System Configuration

### 3.1 Generate Fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
nano /mnt/etc/fstab  # Verify entries
```

### 3.2 Chroot into New System

```bash
arch-chroot /mnt
```

### 3.3 Set Timezone

```bash
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
```

### 3.4 Localization

**Set locale:**

```bash
nano /etc/locale.gen
# Uncomment: en_GB.UTF-8 UTF-8

locale-gen

echo "LANG=en_GB.UTF-8" > /etc/locale.conf
```

**Set console keymap and font:**

```bash
echo "KEYMAP=uk
FONT=lat9w-16" > /etc/vconsole.conf
```

### 3.5 Network Configuration

```bash
# Set hostname
echo "omen-15" > /etc/hostname  # Replace with your preferred hostname

# Enable networking services
systemctl enable systemd-networkd
systemctl enable iwd
systemctl enable dhcpcd

# Configure hosts file
nano /etc/hosts
```

**Add to /etc/hosts:**

```
127.0.0.1    localhost
::1          localhost
127.0.1.1    omen-15.localdomain    omen-15
```

### 3.6 Initramfs

```bash
# Configure if needed
nano /etc/mkinitcpio.conf
```

### 3.7 Set Root Password

```bash
passwd
```

### 3.8 Install Boot Loader

**Install systemd-boot:**

```bash
bootctl install
```

**Get root partition UUID:**

```bash
blkid -s PARTUUID -o value /dev/nvme0n1p3
```

**Configure boot entry:**

```bash
nano /boot/loader/entries/arch.conf
```

**Add to arch.conf:**

```
title    Arch Linux
linux    /vmlinuz-linux
initrd   /initramfs-linux.img
options  root=PARTUUID=<PASTE-UUID-HERE> rw
```

**Configure loader:**

```bash
nano /boot/loader/loader.conf
```

**Add to loader.conf:**

```
default arch
timeout 3
editor 0
```

**Verify boot loader installation:**

```bash
ls /boot/EFI/systemd    # Should show systemd-bootx64.efi
ls /boot/EFI/BOOT       # Should show BOOTX64.EFI
bootctl status
findmnt /boot
```

### 3.9 Reboot

```bash
exit
umount -R /mnt
reboot
```

---

## 4. Post-Installation Setup (Before Running Scripts)

### 4.1 Create User Account

**Login as root, then:**

```bash
# Create user with proper groups
useradd -m -G wheel -s /bin/bash -c "Nabeel" nabeel  # Replace with your name/username

# Set user password
passwd nabeel

# Verify user creation
getent passwd nabeel
```

### 4.2 Connect to WiFi

```bash
# Bring up network interface
ip link
ip link set wlan0 up

# Connect using iwctl
iwctl
device list
station wlan0 get-networks
station wlan0 connect Gigaclear_2109  # Replace with your SSID
exit

# Start DHCP client
dhcpcd wlan0

# Verify connection
ping google.com

# If connection fails, enable iwd service
systemctl enable --now iwd
```

### 4.3 Install Core Desktop Environment

```bash
# Update system
pacman -Syu

# Install GNOME desktop environment
pacman -S gnome gnome-extra gdm
# Select default packages when prompted

# Enable display manager
systemctl enable gdm

# Install NetworkManager for easier network management
pacman -S networkmanager
systemctl enable NetworkManager

# Configure sudo access
EDITOR=nano visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL

# Reboot to start desktop environment
reboot
```

---

## 5. Final Configuration

### 5.1 Fix UK Keyboard Layout

**After logging into GNOME:**

```bash
# Edit locale generation file
sudo nano /etc/locale.gen
# Uncomment: en_GB.UTF-8 UTF-8

sudo locale-gen
```

**Then go to:** Settings → Keyboard to set UK layout

### 5.2 Install Warp Terminal

```bash
# Download from AUR or official package
# Install with: sudo pacman -U warp-terminal-filename.pkg.tar.zst
```

### 5.3 Enable Software Center

```bash
sudo pacman -S gnome-software-packagekit-plugin
```

### 5.4 Configure Bluetooth

```bash
sudo pacman -S bluez-utils
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service
systemctl status bluetooth.service
```

---

## 6. Ready for Post-Installation Scripts

Once you've completed all the above steps and rebooted into your GNOME desktop environment, you're ready to run the automated post-installation scripts from this repository:

```bash
git clone <this-repository-url>
cd arch-setup
chmod +x arch-install.sh
./arch-install.sh
```

The post-installation scripts will handle:
- Package managers (yay, Flatpak)
- Core applications (Discord, Firefox, Opera, etc.)
- Gaming setup (Steam, Wine, NVIDIA libraries)
- Development tools
- GNOME Extensions for system tray support

---

## Notes

- Replace device names (`/dev/nvme0n1`) with your actual disk device
- Replace network names (`Gigaclear_2109`) with your actual WiFi SSID
- Replace hostnames (`omen-15`) and usernames (`nabeel`) with your preferences
- The UUID in the boot configuration must be the actual UUID from your root partition
- Ensure you have a stable internet connection throughout the process

This guide assumes a clean UEFI installation with GNOME desktop environment and NVIDIA graphics card.
