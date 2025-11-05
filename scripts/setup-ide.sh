#!/bin/bash

# Exit on any error
set -e

echo "Setting up development environment..."

# Install essential development tools (git already installed in package-stores setup)
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

# AUR packages in a single install
if ! yay -S --needed --noconfirm \
    visual-studio-code-bin \
    cursor-bin \
    dotnet-sdk-5.0-bin \
    dotnet-runtime-5.0-bin \
    dotnet-targeting-pack-5.0-bin \
    aspnet-runtime-5.0-bin \
    wkhtmltopdf-bin \
    mssql-tools \
    dbeaver \
; then
    echo "Some AUR packages failed to install"
fi

# Enable PHP MySQL extensions
# mysqli
if [ ! -f /etc/php/conf.d/mysqli.ini ] || ! grep -qxF 'extension=mysqli' /etc/php/conf.d/mysqli.ini; then
  echo 'extension=mysqli' | sudo tee /etc/php/conf.d/mysqli.ini >/dev/null
fi
# pdo_mysql
if [ ! -f /etc/php/conf.d/pdo_mysql.ini ] || ! grep -qxF 'extension=pdo_mysql' /etc/php/conf.d/pdo_mysql.ini; then
  echo 'extension=pdo_mysql' | sudo tee /etc/php/conf.d/pdo_mysql.ini >/dev/null
fi

echo "Development environment setup complete"
