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

# Dropbox - via AUR (official desktop client)
echo "📦 Installing Dropbox..."
if ! yay -S --noconfirm dropbox; then
    echo "❌ Failed to install Dropbox"
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

# GNOME desktop essentials
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
    # Power profiles daemon for performance modes in power menu
    echo "⚡ Installing power profiles daemon..."
    sudo pacman -S --needed --noconfirm power-profiles-daemon
    sudo systemctl enable --now power-profiles-daemon
    
    echo "🧩 Installing GNOME Extensions app..."
    if ! flatpak install -y flathub org.gnome.Extensions; then
        echo "⚠️ Failed to install Extensions app"
        echo "You can install it manually from GNOME Software"
    else
        echo "📝 Extensions app installed successfully!"
        
        # Install browser connector for web-based extension installation
        echo "🌐 Installing GNOME browser connector..."
        sudo pacman -S --needed --noconfirm gnome-browser-connector
        
        echo "💡 Extensions setup complete! Next steps:"
        echo "   1. Open Extensions app"
        echo "   2. Go to https://extensions.gnome.org/extension/615/appindicator-support/"
        echo "   3. Install 'AppIndicator and KStatusNotifierItem Support'"
        echo "   4. Enable the extension for Steam/Discord tray icons"
    fi
fi

echo "✅ Core applications installed"
