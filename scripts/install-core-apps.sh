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
if ! yay -S --needed --noconfirm --mflags "--skippgpcheck" opera; then
    echo "Failed to install Opera"
    echo "Continuing with other applications..."
else
    # Install Opera FFmpeg codecs for video playback
    echo "Installing Opera FFmpeg codecs for video support..."
    if ! yay -S --needed --noconfirm opera-ffmpeg-codecs-bin; then
        echo "Failed to install Opera FFmpeg codecs"
        echo "Video playback in Opera may not work properly"
    fi
fi

# Proton Mail (Official Client) - via Flathub
echo "Installing Proton Mail..."
if ! flatpak install -y flathub me.proton.Mail; then
    echo "Failed to install Proton Mail"
    echo "Continuing with other applications..."
fi

# Notion - via AUR (official desktop app)
echo "Installing Notion..."
if ! yay -S --needed --noconfirm notion-app-electron; then
    echo "Failed to install Notion"
    echo "Continuing with other applications..."
fi

# Cursor IDE - AI-first coding environment via AUR
echo "Installing Cursor IDE..."
if ! yay -S --needed --noconfirm cursor-bin; then
    echo "Failed to install Cursor IDE"
    echo "Continuing with other applications..."
fi

# Essential utilities and media support via pacman
echo "Installing essential utilities and media support..."
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
    ffmpeg \
    libva-mesa-driver \
    pipewire-pulse \
    wireplumber \
    alsa-utils \
    qbittorrent; then
    echo "Some utilities, codecs, or qBittorrent failed to install"
    echo "Continuing with other applications..."
fi


# Additional browser video/audio support packages
echo "Installing additional browser video support..."
if ! sudo pacman -S --needed --noconfirm \
    lib32-mesa \
    lib32-libva-mesa-driver \
    lib32-mesa-vdpau \
    libva-utils \
    vdpauinfo \
    pulseaudio-alsa; then
    echo "Some browser video support packages failed to install"
    echo "Video playback in browsers may have issues"
fi

# NVIDIA-specific video acceleration (if NVIDIA GPU detected)
if lspci | grep -i nvidia > /dev/null; then
    echo "NVIDIA GPU detected, installing NVIDIA video acceleration..."
    if ! sudo pacman -S --needed --noconfirm \
        libva-nvidia-driver \
        lib32-libva-nvidia-driver \
        nvidia-prime; then
        echo "Failed to install NVIDIA video acceleration packages"
        echo "NVIDIA video acceleration may not work properly"
    fi
else
    echo "No NVIDIA GPU detected, skipping NVIDIA-specific packages"
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
