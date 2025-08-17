#!/bin/bash

# GNOME Desktop Configuration
# Configures GNOME desktop settings for better user experience

set -e

echo "🖥️  Configuring GNOME desktop settings..."

# Check if running GNOME
if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ]; then
    echo "⚠️  Warning: Not running GNOME desktop environment"
    echo "   Current desktop: ${XDG_CURRENT_DESKTOP:-Unknown}"
    echo "   Skipping GNOME-specific configurations"
    exit 0
fi

# Check if running under Wayland (recommended for fractional scaling)
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "✅ Running Wayland session - enabling experimental features for better scaling"
    
    # Enable fractional scaling support
    echo "🔧 Enabling fractional scaling and native XWayland scaling..."
    gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'xwayland-native-scaling']"
    
    echo "✅ Fractional scaling enabled!"
    echo "   You can now set fractional display scaling in Settings > Displays"
else
    echo "⚠️  Running X11 session"
    echo "   Fractional scaling works best with Wayland"
    echo "   Consider switching to Wayland session for better scaling support"
fi

echo "🎨 GNOME configuration complete!"
