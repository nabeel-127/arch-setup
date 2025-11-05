#!/bin/bash

# Exit on any error
set -e

echo "Installing core applications..."

# Single pacman invocation for all pacman-managed packages
if ! sudo pacman -S --needed --noconfirm \
	discord \
	firefox \
	net-tools \
	htop \
	fastfetch \
	tree \
	unzip \
	wget \
	curl \
	vi \
	vim \
	nano \
	iw \
	wireless_tools \
	grub \
	gst-plugins-base \
	gst-plugins-good \
	ffmpeg \
	libva-mesa-driver \
	pipewire-pulse \
	wireplumber \
	alsa-utils \
	qbittorrent \
	libreoffice-still \
	lib32-mesa \
	lib32-libva-mesa-driver \
	lib32-mesa-vdpau \
	libva-utils \
	vdpauinfo \
	pulseaudio-alsa \
	$(lspci | grep -qi nvidia && echo "libva-nvidia-driver lib32-libva-nvidia-driver nvidia-prime") \
	$( [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]] && echo "gnome-disk-utility power-profiles-daemon gnome-browser-connector libayatana-appindicator libappindicator-gtk3") \
; then
	echo "Some pacman packages failed to install"
fi

if ! yay -S --needed --noconfirm \
	notion-app-electron \
	woeusb \
; then
	echo "Some AUR packages failed to install"
fi

if ! flatpak install -y flathub \
	com.opera.Opera \
	me.proton.Mail \
	com.dropbox.Client \
	com.microsoft.Edge \
	$( [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]] && echo "org.gnome.Extensions") \
; then
	echo "Some Flatpak apps failed to install"
fi

# Enable GNOME power profiles if on GNOME
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
	if ! systemctl is-enabled --quiet power-profiles-daemon 2>/dev/null; then
		if ! sudo systemctl enable power-profiles-daemon; then echo "Failed to enable power-profiles-daemon"; fi
	fi
	if ! systemctl is-active --quiet power-profiles-daemon 2>/dev/null; then
		if ! sudo systemctl start power-profiles-daemon; then echo "Failed to start power-profiles-daemon"; fi
	fi
fi

echo "Core applications installed"
