#!/bin/bash

set -e

echo "Configuring thermal management..."

# Install required packages (single per manager)
if ! sudo pacman -S --needed --noconfirm lm_sensors; then
    echo "Failed to install lm_sensors"
fi

if ! yay -S --needed --noconfirm nbfc-linux; then
    echo "Failed to install nbfc-linux"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_SRC="$SCRIPT_DIR/../configs/HP OMEN Laptop 15-en0xxx Aggressive.json"
DEST_DIR="/usr/share/nbfc/configs"
DEST_FILE="$DEST_DIR/HP OMEN Laptop 15-en0xxx Aggressive.json"

# Ensure destination directory exists
if [[ ! -d "$DEST_DIR" ]]; then
    sudo mkdir -p "$DEST_DIR"
fi

# Copy NBFC profile only if missing or different
if [[ -f "$PROFILE_SRC" ]]; then
    if [[ ! -f "$DEST_FILE" ]] || ! cmp -s "$PROFILE_SRC" "$DEST_FILE"; then
        if ! sudo cp "$PROFILE_SRC" "$DEST_DIR/"; then
            echo "Failed to copy NBFC profile"
        fi
    fi
else
    echo "NBFC profile not found at $PROFILE_SRC (skipping copy)"
fi

# Apply profile only if not already active
if command -v nbfc >/dev/null 2>&1; then
    if ! sudo nbfc config --get 2>/dev/null | grep -q "HP OMEN Laptop 15-en0xxx Aggressive"; then
        if ! sudo nbfc config --apply "HP OMEN Laptop 15-en0xxx Aggressive"; then
            echo "Failed to apply NBFC profile"
        fi
    fi

    # Enable and start nbfc service idempotently
    if ! systemctl is-enabled nbfc_service >/dev/null 2>&1; then
        sudo systemctl enable nbfc_service
    fi
    if ! systemctl is-active nbfc_service >/dev/null 2>&1; then
        sudo systemctl start nbfc_service
    fi

    if ! sudo nbfc set --auto; then
        echo "Failed to set NBFC auto mode"
    fi
fi

echo "Thermal management configured successfully!"
