#!/bin/bash

# Exit on any error
set -e

echo "Setting up gaming..."

# Ensure multilib repository is enabled (required by Steam)
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf >/dev/null
    sudo pacman -Sy
fi

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
    lib32-gamemode \
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
    lib32-gtk3 \
    steam \
    steam-native-runtime \
    mangohud \
    lib32-mangohud \
    $(lspci | grep -qi nvidia && echo "lib32-nvidia-utils nvidia-prime") \
; then
    echo "Some gaming packages failed to install"
fi

if ! flatpak install -y flathub com.heroicgameslauncher.hgl; then
    echo "Failed to install Heroic Games Launcher"
fi

# Ensure GameMode user service is enabled and active (idempotent)
if ! systemctl --user is-enabled --quiet gamemoded.service 2>/dev/null; then
    if ! systemctl --user enable gamemoded.service; then
        echo "Failed to enable GameMode service"
    fi
fi
if ! systemctl --user is-active --quiet gamemoded.service 2>/dev/null; then
    if ! systemctl --user start gamemoded.service; then
        echo "Failed to start GameMode service"
    fi
fi

# Add user to gamemode group only if missing
TARGET_USER="${SUDO_USER:-$USER}"
if ! id -nG "$TARGET_USER" | grep -qw gamemode; then
    if ! sudo usermod -aG gamemode "$TARGET_USER"; then
        echo "Failed to add user to gamemode group"
    fi
fi

echo "Gaming setup complete"
