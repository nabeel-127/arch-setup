#!/bin/bash

# Exit on any error
set -e

echo "Setting up gaming..."

# Enable multilib repository (REQUIRED by Steam - Steam is 32-bit and needs 32-bit libraries)
echo "🔧 Enabling multilib repository for Steam support..."
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
    echo "Adding multilib repository to pacman.conf..."
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
    echo "Updating package database..."
    sudo pacman -Sy
else
    echo "✅ multilib repository already enabled"
fi

# Install Wine and related tools first (dependencies for gaming)
echo "🍷 Installing Wine and gaming dependencies..."
sudo pacman -S --needed --noconfirm \
    wine \
    winetricks \
    lib32-mesa \
    lib32-vulkan-radeon \
    lib32-vulkan-intel \
    vulkan-tools \
    gamemode \
    lib32-gamemode

# Install Steam (REQUIRES multilib for 32-bit support)
echo "🎮 Installing Steam..."
sudo pacman -S --needed --noconfirm steam

# Install Steam native runtime (alternative to Steam Runtime)
echo "🔧 Installing Steam native runtime..."
if ! sudo pacman -S --needed --noconfirm steam-native-runtime; then
    echo "⚠️ Failed to install steam-native-runtime (non-critical)"
fi

# Install Heroic Games Launcher via flatpak
echo "⚔️ Installing Heroic Games Launcher..."
if ! flatpak install -y flathub com.heroicgameslauncher.hgl; then
    echo "❌ Failed to install Heroic Games Launcher"
    exit 1
fi

# Install MangoHud for performance monitoring
echo "📊 Installing MangoHud..."
if ! sudo pacman -S --needed --noconfirm mangohud lib32-mangohud; then
    echo "⚠️ Failed to install MangoHud (non-critical)"
fi

echo "✅ Gaming setup complete"
echo "📝 Gaming tools installed:"
echo "  - Steam (with required multilib support)"
echo "  - Heroic Games Launcher (Epic/GOG)"
echo "  - Wine + Winetricks (Windows compatibility)"
echo "  - Vulkan drivers and tools"
echo "  - GameMode (performance optimization)"
echo "  - MangoHud (performance overlay)"
echo ""
echo "📋 Note: Multilib repository was enabled because Steam requires 32-bit libraries"
