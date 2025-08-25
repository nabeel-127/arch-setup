#!/bin/bash

# Install Wireless Regulatory Database (CRITICAL FIX)
# Fixes massive WiFi jitter by enabling proper regulatory domain
# Run with: sudo ./install-wireless-regdb.sh

echo "1) Install wireless-regdb (CRITICAL - fixes jitter)"
echo "2) Check regulatory database status"
read -p "Choice [1-2]: " choice

if [ "$choice" = "1" ]; then
    echo "Installing wireless regulatory database..."
    sudo pacman -S wireless-regdb
    echo "✓ Wireless regulatory database installed"
    echo "Reboot required for full effect"
    
elif [ "$choice" = "2" ]; then
    echo "=== REGULATORY DATABASE STATUS ==="
    if pacman -Q wireless-regdb >/dev/null 2>&1; then
        echo "✓ wireless-regdb is installed"
        echo "Current regulatory domain:"
        iw reg get | head -5
    else
        echo "❌ wireless-regdb NOT installed"
        echo "This is likely causing your WiFi jitter!"
    fi
    
else
    echo "Invalid choice"
    exit 1
fi
