#!/bin/bash

set -e

handle_error() {
    echo "Error on line $1. Exiting."
    exit 1
}

trap 'handle_error $LINENO' ERR

echo "Arch Linux Post-Installation Setup"
echo "===================================="

# Check sudo access and extend timeout
sudo -v
sudo bash -c 'echo "Defaults timestamp_timeout=60" >> /etc/sudoers.d/temp_install_timeout' 2>/dev/null || true

# Update system
sudo pacman -Syu --noconfirm

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Make all scripts executable
chmod +x "$SCRIPT_DIR"/scripts/*.sh "$SCRIPT_DIR"/utils/*.sh 2>/dev/null || true

# Ask upfront which optional scripts to run
echo
echo "Select which optional components to install:"
echo "1. Entertainment applications"
echo "2. Gaming setup (Steam, Wine, etc.)"
echo "3. Development environment (IDE, dev tools)"
echo "4. Thermal management (critical for HP laptops)"
echo "5. Network optimization (reduces WiFi jitter)"
echo "6. GNOME desktop configuration"
echo "7. SSH keys setup"
echo
read -p "Enter selections (e.g., 1,2,3 or 'all' for everything): " selections

# Parse selections
INSTALL_ENTERTAINMENT=false
INSTALL_GAMING=false
INSTALL_IDE=false
INSTALL_THERMAL=false
INSTALL_NETWORK=false
INSTALL_GNOME=false
INSTALL_SSH=false

if [[ "$selections" == "all" ]]; then
    INSTALL_ENTERTAINMENT=true
    INSTALL_GAMING=true
    INSTALL_IDE=true
    INSTALL_THERMAL=true
    INSTALL_NETWORK=true
    INSTALL_GNOME=true
    INSTALL_SSH=true
else
    IFS=',' read -ra ADDR <<< "$selections"
    for i in "${ADDR[@]}"; do
        case "${i// /}" in
            1) INSTALL_ENTERTAINMENT=true ;;
            2) INSTALL_GAMING=true ;;
            3) INSTALL_IDE=true ;;
            4) INSTALL_THERMAL=true ;;
            5) INSTALL_NETWORK=true ;;
            6) INSTALL_GNOME=true ;;
            7) INSTALL_SSH=true ;;
        esac
    done
fi

echo
echo "Starting installation (core apps will always be installed)..."
echo

# Always run these core scripts
bash "$SCRIPT_DIR/scripts/setup-package-stores.sh"
bash "$SCRIPT_DIR/scripts/install-core-apps.sh"

# Run optional scripts based on selection
if [ "$INSTALL_ENTERTAINMENT" = true ]; then
    bash "$SCRIPT_DIR/scripts/install-entertainment.sh"
fi

if [ "$INSTALL_GAMING" = true ]; then
    bash "$SCRIPT_DIR/scripts/setup-gaming.sh"
fi

if [ "$INSTALL_IDE" = true ]; then
    bash "$SCRIPT_DIR/scripts/setup-ide.sh"
fi

if [ "$INSTALL_THERMAL" = true ]; then
    bash "$SCRIPT_DIR/scripts/setup-thermal.sh"
fi

if [ "$INSTALL_NETWORK" = true ]; then
    bash "$SCRIPT_DIR/scripts/setup-network-optimization.sh"
fi

if [ "$INSTALL_GNOME" = true ]; then
    bash "$SCRIPT_DIR/utils/setup-gnome.sh"
fi

if [ "$INSTALL_SSH" = true ]; then
    bash "$SCRIPT_DIR/utils/setup-ssh.sh"
fi

# System cleanup
sudo pacman -Rns --noconfirm $(pacman -Qtdq) 2>/dev/null || true

# Clean up sudo timeout
sudo rm -f /etc/sudoers.d/temp_install_timeout

echo
echo "Arch Linux setup complete!"
echo "Please reboot to ensure all changes take effect."
