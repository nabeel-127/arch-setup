#!/bin/bash

# Exit on any error
set -e

# Function to handle errors
handle_error() {
    echo "❌ Error on line $1. Exiting."
    exit 1
}

# Trap errors
trap 'handle_error $LINENO' ERR

echo "🏛️ Arch Linux Post-Installation Setup"
echo "====================================="

# Check if user has sudo access and extend timeout to avoid multiple prompts
echo "🔐 Checking sudo access and extending timeout..."
sudo -v
# Extend sudo timeout to 60 minutes to avoid repeated password prompts
sudo bash -c 'echo "Defaults timestamp_timeout=60" >> /etc/sudoers.d/temp_install_timeout'

# Update system first
echo "📦 Updating system packages..."
sudo pacman -Syu --noconfirm

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Make all scripts executable
echo "🔧 Making all scripts executable..."
chmod +x "$SCRIPT_DIR"/scripts/*.sh "$SCRIPT_DIR"/utils/*.sh

# Run setup scripts in order
echo "🏪 Setting up package managers and AUR helper..."
bash "$SCRIPT_DIR/scripts/setup-package-stores.sh"

echo "📱 Installing core applications..."
bash "$SCRIPT_DIR/scripts/install-core-apps.sh"

echo "🎯 Setting up gaming..."
bash "$SCRIPT_DIR/scripts/setup-gaming.sh"

# Ask if user wants to setup SSH keys
echo
read -p "🔑 Do you want to setup SSH keys for Git? (y/n): " setup_ssh
case "$setup_ssh" in
    [Yy]|[Yy][Ee][Ss])
        echo "🔑 Setting up SSH keys..."
        bash "$SCRIPT_DIR/utils/setup-ssh.sh"
        ;;
    *)
        echo "⏭️ Skipping SSH setup"
        ;;
esac

echo "💻 Setting up development environment..."
bash "$SCRIPT_DIR/scripts/setup-ide.sh"

echo "🖥️  Configuring GNOME desktop..."
bash "$SCRIPT_DIR/utils/setup-gnome.sh"

# Clean up sudo timeout extension
echo "🧹 Cleaning up temporary sudo settings..."
sudo rm -f /etc/sudoers.d/temp_install_timeout

echo "✅ Arch Linux setup complete!"
echo "🔄 Please reboot to ensure all changes take effect."
