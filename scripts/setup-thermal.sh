#!/bin/bash

set -e

# Install laptop fan control packages
sudo pacman -S --needed --noconfirm lm_sensors
yay -S --needed --noconfirm nbfc-linux

# Configure NBFC for HP OMEN laptop
sudo nbfc config --apply "HP OMEN Laptop 15-en0xxx"

# Enable and start nbfc service
sudo systemctl enable --now nbfc_service
sudo nbfc set --auto

echo "Thermal management configured successfully!"
