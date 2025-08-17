#!/bin/bash

# Exit on any error
set -e

echo "Setting up SSH keys for Git..."

# Ask for email
read -p "Enter your email for SSH key: " email

if [[ -z "$email" ]]; then
    echo "❌ Email cannot be empty"
    exit 1
fi

# Generate SSH key
echo "Generating SSH key..."
if ! ssh-keygen -t ed25519 -C "$email"; then
    echo "❌ Failed to generate SSH key"
    exit 1
fi

# Start SSH agent and add key
echo "Adding key to SSH agent..."
if ! eval "$(ssh-agent -s)"; then
    echo "❌ Failed to start SSH agent"
    exit 1
fi

if ! ssh-add ~/.ssh/id_ed25519; then
    echo "❌ Failed to add key to SSH agent"
    exit 1
fi

echo
echo "Your SSH public key (copy this):"
echo "================================="
cat ~/.ssh/id_ed25519.pub
echo
echo "Add this to:"
echo "GitHub: https://github.com/settings/keys"
echo "GitLab: https://gitlab.com/-/profile/keys"
