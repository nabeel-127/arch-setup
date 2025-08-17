#!/bin/bash

# Exit on any error
set -e

echo "Installing core applications..."

# Discord - via pacman
echo "💬 Installing Discord..."
sudo pacman -S --needed --noconfirm discord

# Firefox - via pacman  
echo "🦊 Installing Firefox..."
sudo pacman -S --needed --noconfirm firefox

# Opera - via AUR (skip PGP verification as it's a binary package from Opera)
echo "🎭 Installing Opera..."
if ! yay -S --noconfirm --mflags "--skippgpcheck" opera; then
    echo "⚠️ Failed to install Opera"
    echo "Continuing with other applications..."
fi

# ProtonMail Bridge - via Flathub
echo "📧 Installing ProtonMail Bridge..."
if ! flatpak install -y flathub ch.protonmail.protonmail-bridge; then
    echo "❌ Failed to install ProtonMail Bridge"
    echo "Continuing with other applications..."
fi

# Notion - via AUR (official desktop app)
echo "📝 Installing Notion..."
if ! yay -S --noconfirm notion-app-electron; then
    echo "❌ Failed to install Notion"
    echo "Continuing with other applications..."
fi

# Essential utilities (neofetch replaced with fastfetch in Arch)
echo "🔧 Installing essential utilities..."
sudo pacman -S --needed --noconfirm \
    htop \
    fastfetch \
    tree \
    unzip \
    wget \
    curl \
    vim \
    nano

echo "✅ Core applications installed"
