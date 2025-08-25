#!/bin/bash

# Exit on any error
set -e

echo "Setting up development environment..."

# Install essential development tools (git already installed in package-stores setup)
echo "Installing essential development tools..."
sudo pacman -S --needed --noconfirm \
    nodejs \
    npm \
    python \
    python-pip \
    dotnet-sdk \
    docker \
    docker-compose \
    curl \
    cmake \
    jq \
    openbsd-netcat \
    postgresql

echo "Development environment setup complete"
