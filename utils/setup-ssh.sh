#!/bin/bash

# Exit on any error
set -e

echo "Setting up SSH keys for Git..."

# Ask for email
read -p "Enter your email for SSH key: " email

if [[ -z "$email" ]]; then
    echo "Email cannot be empty"
    exit 1
fi

# Ask for each key type
read -p "Do you want to generate an ed25519 SSH key? (y/N): " generate_ed25519
read -p "Do you want to generate an RSA SSH key? (y/N): " generate_rsa

# Generate SSH keys based on user choice
generated_keys=()

if [[ "$generate_ed25519" =~ ^[Yy]$ ]]; then
    echo "Generating ed25519 SSH key..."
    if ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519; then
        generated_keys+=("ed25519")
    else
        echo "Failed to generate ed25519 SSH key"
    fi
fi

if [[ "$generate_rsa" =~ ^[Yy]$ ]]; then
    echo "Generating RSA SSH key..."
    if ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa; then
        generated_keys+=("rsa")
    else
        echo "Failed to generate RSA SSH key"
    fi
fi

# Check if any keys were generated
if [[ ${#generated_keys[@]} -eq 0 ]]; then
    echo "No SSH keys were generated. Exiting."
    exit 0
fi

# Start SSH agent and add keys
echo "Adding keys to SSH agent..."
if ! eval "$(ssh-agent -s)"; then
    echo "Failed to start SSH agent"
    exit 1
fi

if ! ssh-add ~/.ssh/id_ed25519; then
    echo "Failed to add ed25519 key to SSH agent"
    exit 1
fi

if ! ssh-add ~/.ssh/id_rsa; then
    echo "Failed to add RSA key to SSH agent"
    exit 1
fi

echo
echo "Your SSH public keys (copy these):"
echo "===================================="
echo "ed25519:"
cat ~/.ssh/id_ed25519.pub
echo
echo "RSA:"
cat ~/.ssh/id_rsa.pub
echo
echo "Add these to:"
echo "GitHub: https://github.com/settings/keys"
echo "GitLab: https://gitlab.com/-/profile/keys"
