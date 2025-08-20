#!/bin/bash

# Exit on any error
set -e

echo "Setting up gaming..."

# Enable multilib repository (REQUIRED by Steam - Steam is 32-bit and needs 32-bit libraries)
echo "Enabling multilib repository for Steam support..."
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
    echo "Adding multilib repository to pacman.conf..."
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
    echo "Updating package database..."
    sudo pacman -Sy
else
    echo "multilib repository already enabled"
fi

# Install Wine and related tools first (dependencies for gaming)
echo "Installing Wine and gaming dependencies..."
if ! sudo pacman -S --needed --noconfirm \
    wine \
    winetricks \
    wine-mono \
    wine-gecko \
    vkd3d \
    lib32-vkd3d \
    lib32-mesa \
    lib32-vulkan-radeon \
    lib32-vulkan-intel \
    vulkan-tools \
    gamemode \
    lib32-gamemode; then
    echo "Failed to install some Wine/gaming dependencies"
fi

# Install additional dependencies for Epic Games Store games (like Rocket League)
echo "Installing Epic Games Store dependencies..."
if ! sudo pacman -S --needed --noconfirm \
    lib32-gnutls \
    lib32-libldap \
    lib32-libgpg-error \
    lib32-sqlite \
    lib32-libpulse \
    lib32-openal \
    lib32-v4l-utils \
    lib32-libxcomposite \
    lib32-libxinerama \
    lib32-libxslt \
    lib32-libva \
    lib32-gtk3; then
    echo "Failed to install some Epic Games Store dependencies"
fi

# Install NVIDIA 32-bit libraries for Steam games (if NVIDIA GPU detected)
if lspci | grep -qi nvidia; then
    echo "Installing NVIDIA 32-bit libraries for gaming..."
    if ! sudo pacman -S --needed --noconfirm lib32-nvidia-utils; then
        echo "Failed to install lib32-nvidia-utils"
    fi
fi

# Install Steam (REQUIRES multilib for 32-bit support)
echo "Installing Steam..."
if ! sudo pacman -S --needed --noconfirm steam; then
    echo "Failed to install Steam"
    exit 1
fi

# Install Steam native runtime (alternative to Steam Runtime)
echo "Installing Steam native runtime..."
if ! sudo pacman -S --needed --noconfirm steam-native-runtime; then
    echo "Failed to install steam-native-runtime (non-critical)"
fi

# Install Heroic Games Launcher via flatpak
echo "Installing Heroic Games Launcher..."
if ! flatpak install -y flathub com.heroicgameslauncher.hgl; then
    echo "Failed to install Heroic Games Launcher"
    exit 1
fi

# Install MangoHud for performance monitoring
echo "Installing MangoHud..."
if ! sudo pacman -S --needed --noconfirm mangohud lib32-mangohud; then
    echo "Failed to install MangoHud (non-critical)"
fi

# Configure GameMode service and permissions
echo "Configuring GameMode service..."
# Enable and start GameMode daemon for current user
if ! systemctl --user enable --now gamemoded.service; then
    echo "Failed to enable GameMode service (non-critical)"
fi

# Add user to gamemode group for proper permissions
if ! sudo usermod -aG gamemode $USER; then
    echo "Failed to add user to gamemode group (non-critical)"
fi

echo "Gaming setup complete"
