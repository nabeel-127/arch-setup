#!/bin/bash

# Exit on any error
set -e

echo "Setting up development environment..."

# Install essential development tools (git already installed in package-stores setup)
echo "🔨 Installing essential development tools..."
sudo pacman -S --needed --noconfirm \
    nodejs \
    npm \
    python \
    python-pip

echo "✅ Development environment setup complete"
echo "📝 Development tools installed:"
echo "  - Essential build tools (base-devel) - installed with AUR helper"
echo "  - Git version control - installed with AUR helper"
echo "  - Node.js and npm"
echo "  - Python and pip"
echo ""
echo "💡 Note: No code editor installed - add your preferred one manually"
