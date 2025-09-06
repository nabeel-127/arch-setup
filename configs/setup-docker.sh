#!/bin/bash
set -e

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group if not already
if ! groups $USER | grep -q docker; then
    sudo usermod -aG docker $USER
    echo "Added $USER to docker group. Logout/login required."
else
    echo "$USER already in docker group."
fi

echo "Docker setup complete."
