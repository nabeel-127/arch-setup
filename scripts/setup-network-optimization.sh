#!/bin/bash

# Network optimization for Intel WiFi cards
# Run with: ./setup-network-optimization.sh

set -e

if ! lspci | grep -q "Intel.*Wi-Fi"; then
    echo "No Intel WiFi detected. Skipping."
    exit 0
fi

echo "1) Install iwlwifi-lar-disable-dkms (may fix WiFi jitter)"
echo "2) Skip"
read -p "Choice [1-2]: " choice

if [ "$choice" = "1" ]; then
    yay -S iwlwifi-lar-disable-dkms --noconfirm
    echo "Installed. Reboot required."
fi
