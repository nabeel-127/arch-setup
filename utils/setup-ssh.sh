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


# Generate SSH keys
echo "Generating ed25519 SSH key..."
if ! ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519; then
    echo "Failed to generate ed25519 SSH key"
fi

echo "Generating RSA SSH key..."
if ! ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa; then
    echo "Failed to generate RSA SSH key"
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
