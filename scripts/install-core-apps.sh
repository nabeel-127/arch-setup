#!/bin/bash

# Exit on any error
set -e

echo "Installing core applications..."

# Core applications via pacman
echo "Installing Discord and Firefox..."
if ! sudo pacman -S --needed --noconfirm discord firefox; then
    echo "Failed to install some core applications"
    echo "Continuing with other applications..."
fi

# Opera - via AUR (skip PGP verification as it's a binary package from Opera)
echo "Installing Opera..."
if ! yay -S --noconfirm --mflags "--skippgpcheck" opera; then
    echo "Failed to install Opera"
    echo "Continuing with other applications..."
fi

# Proton Mail (Official Client) - via Flathub
echo "Installing Proton Mail..."
if ! flatpak install -y flathub me.proton.Mail; then
    echo "Failed to install Proton Mail"
    echo "Continuing with other applications..."
fi

# Notion - via AUR (official desktop app)
echo "Installing Notion..."
if ! yay -S --noconfirm notion-app-electron; then
    echo "Failed to install Notion"
    echo "Continuing with other applications..."
fi

# Essential utilities, video codecs, and qBittorrent via pacman
echo "Installing essential utilities and codecs..."
if ! sudo pacman -S --needed --noconfirm \
    htop \
    fastfetch \
    tree \
    unzip \
    wget \
    curl \
    vim \
    nano \
    iw \
    wireless_tools \
    gst-plugins-base \
    gst-plugins-good \
    gst-plugins-bad \
    gst-plugins-ugly \
    gst-libav \
    ffmpeg \
    libva-mesa-driver \
    libvdpau-va-gl \
    mesa-vdpau \
    x264 \
    x265 \
    libde265 \
    libvpx \
    opus \
    qbittorrent; then
    echo "Some utilities, codecs, or qBittorrent failed to install"
    echo "Continuing with other applications..."
fi

# GNOME desktop essentials
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
    # GNOME essentials via pacman
    echo "Installing GNOME essentials..."
    if ! sudo pacman -S --needed --noconfirm power-profiles-daemon gnome-browser-connector; then
        echo "Failed to install some GNOME essentials"
        echo "Continuing with other applications..."
    else
        sudo systemctl enable --now power-profiles-daemon
    fi
    
    # Install libappindicator for tray icon support (required by Discord, etc.)
    echo "Installing AppIndicator libraries..."
    if ! sudo pacman -S --needed --noconfirm libayatana-appindicator libappindicator-gtk3; then
        echo "Failed to install AppIndicator libraries"
        echo "Tray icons for Discord and other apps may not work properly"
    fi
    
    echo "Installing GNOME Extensions app..."
    if ! flatpak install -y flathub org.gnome.Extensions; then
        echo "Failed to install Extensions app"
    fi
fi

echo "Core applications installed"
