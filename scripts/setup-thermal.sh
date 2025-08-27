#!/bin/bash

set -e

# Install laptop fan control packages
sudo pacman -S --needed --noconfirm lm_sensors
yay -S --needed --noconfirm nbfc-linux

# Copy custom aggressive cooling profile from repo to system configs
sudo cp "$(dirname "$0")/../configs/HP OMEN Laptop 15-en0xxx Aggressive.json" /usr/share/nbfc/configs/

# Configure NBFC for HP OMEN laptop (aggressive cooling profile)
sudo nbfc config --apply "HP OMEN Laptop 15-en0xxx Aggressive"

# Enable and start nbfc service
sudo systemctl enable --now nbfc_service
sudo nbfc set --auto

echo "Thermal management configured successfully!"
