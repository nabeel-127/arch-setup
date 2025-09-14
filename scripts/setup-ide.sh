#!/bin/bash

# Exit on any error
set -e

echo "Setting up development environment..."

# Install Visual Studio Code - official Microsoft build via AUR
echo "Installing Visual Studio Code (official Microsoft build)..."
if ! yay -S --needed --noconfirm visual-studio-code-bin; then
    echo "Failed to install Visual Studio Code"
    echo "Continuing with other development tools..."
fi

# Install essential development tools (git already installed in package-stores setup)
echo "Installing essential development tools..."
sudo pacman -S --needed --noconfirm \
    nodejs \
    npm \
    python \
    python-pip \
    dotnet-sdk \
    aspnet-runtime \
    docker \
    docker-compose \
    cmake \
    jq \
    openbsd-netcat \
    postgresql \
    mariadb \
    apache \
    php \
    php-apache \
    phpmyadmin

# Enable PHP MySQL extensions
echo 'extension=mysqli' | sudo tee /etc/php/conf.d/mysqli.ini
echo 'extension=pdo_mysql' | sudo tee /etc/php/conf.d/pdo_mysql.ini

echo "Development environment setup complete"
