#!/bin/bash

# Permanent WiFi Power Management Control
# Run with: sudo ./wifi-power-permanent.sh

UDEV_FILE="/etc/udev/rules.d/80-wifi-powersave.rules"

echo "1) Disable power save permanently (survives reboot)"
echo "2) Remove permanent disable (restore default)"
read -p "Choice [1-2]: " choice

if [ "$choice" = "1" ]; then
    sudo bash -c "cat > $UDEV_FILE << 'EOF'
ACTION==\"add\", SUBSYSTEM==\"net\", KERNEL==\"wlan*\", RUN+=\"/usr/bin/iw dev \$name set power_save off\"
EOF"
    sudo iw dev wlan0 set power_save off
    echo "✓ Power save permanently disabled"
    
elif [ "$choice" = "2" ]; then
    sudo rm -f "$UDEV_FILE"
    sudo iw dev wlan0 set power_save on
    echo "✓ Permanent disable removed"
    
else
    echo "Invalid choice"
    exit 1
fi
