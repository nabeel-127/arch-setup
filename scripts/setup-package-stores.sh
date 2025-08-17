#!/bin/bash

# Exit on any error
set -e

echo "Setting up package managers and AUR helper..."

# Install base-devel and git (required for building AUR packages)
echo "🔨 Installing base-devel and git for AUR support..."
sudo pacman -S --needed --noconfirm base-devel git

# Install yay (AUR helper) - official method from AUR
echo "📦 Installing yay (AUR helper)..."
if ! command -v yay &> /dev/null; then
    # Use /tmp for temporary files
    YAY_TEMP_DIR="/tmp/yay-install-$$"
    mkdir -p "$YAY_TEMP_DIR"
    cd "$YAY_TEMP_DIR"
    
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    
    # Clean up temporary files
    cd /
    rm -rf "$YAY_TEMP_DIR"
    echo "✅ yay installed successfully and temp files cleaned"
else
    echo "✅ yay already installed"
fi

# Install Flatpak (official Arch package)
echo "🏦 Installing Flatpak..."
sudo pacman -S --needed --noconfirm flatpak

# Add Flathub repository (official Flatpak repo)
echo "🏦 Adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "✅ Package managers setup complete"
echo "📝 Available package managers:"
echo "  - pacman (official Arch repositories)"
echo "  - yay (AUR helper for Arch User Repository)"
echo "  - flatpak (Flathub applications)"
