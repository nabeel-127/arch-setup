#!/bin/bash

# NetworkManager WiFi Override Fix - Prevent NM from overriding gaming optimizations

echo "=== NetworkManager WiFi Override Fix ==="
echo "NetworkManager status: $(systemctl is-active NetworkManager)"
echo "Current WiFi management: $(nmcli device status | grep wlan0 | awk '{print $3}')"
echo
echo "Problem: NetworkManager resets WiFi settings, undoing gaming optimizations"
echo "Solution: Configure NetworkManager to preserve custom WiFi settings"
echo
echo "1) Prevent NM WiFi override    2) Allow NM management    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Configuring NetworkManager to preserve WiFi optimizations..."
        
        # Create NetworkManager configuration directory if it doesn't exist
        sudo mkdir -p /etc/NetworkManager/conf.d
        
        # Create configuration to prevent WiFi setting overrides
        sudo tee /etc/NetworkManager/conf.d/99-wifi-preserve-settings.conf > /dev/null << 'EOF'
[main]
# Preserve custom WiFi settings for gaming optimizations

[connection]
# Don't modify WiFi interface settings
wifi.powersave=2

[device-wifi-preserve]
# Preserve queue discipline and custom settings
match-device=interface-name:wlan0
managed=1
EOF
        
        # Create script to reapply settings after NetworkManager changes
        sudo tee /etc/NetworkManager/dispatcher.d/99-wifi-gaming-fix > /dev/null << 'EOF'
#!/bin/bash
# Reapply gaming WiFi optimizations after NetworkManager events

if [ "$1" = "wlan0" ] && [ "$2" = "up" ]; then
    # Wait for interface to stabilize
    sleep 2
    
    # Reapply fq_codel if it was reset
    current_qdisc=$(tc qdisc show dev wlan0 | awk '{print $2}')
    if [ "$current_qdisc" = "noqueue" ]; then
        tc qdisc replace dev wlan0 root fq_codel 2>/dev/null || true
    fi
    
    # Ensure power save is off
    iw dev wlan0 set power_save off 2>/dev/null || true
fi
EOF
        
        # Make dispatcher script executable
        sudo chmod +x /etc/NetworkManager/dispatcher.d/99-wifi-gaming-fix
        
        # Reload NetworkManager configuration
        sudo systemctl reload NetworkManager
        
        echo "✓ NetworkManager configured to preserve WiFi settings"
        echo "✓ Dispatcher script installed for automatic reapplication"
        echo "✓ WiFi optimizations will persist through NM changes"
        ;;
    2)
        echo "Removing NetworkManager WiFi override prevention..."
        
        # Remove configuration files
        sudo rm -f /etc/NetworkManager/conf.d/99-wifi-preserve-settings.conf
        sudo rm -f /etc/NetworkManager/dispatcher.d/99-wifi-gaming-fix
        
        # Reload NetworkManager
        sudo systemctl reload NetworkManager
        
        echo "✓ NetworkManager override prevention removed"
        echo "✓ NetworkManager will manage WiFi settings normally"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
