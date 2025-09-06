#!/bin/bash

# Intel WiFi Packet Batching Fix - Disable iwlwifi packet batching/aggregation

echo "=== Intel WiFi Packet Batching Fix ==="
echo "Problem: iwlwifi driver batches packets under sustained load (pipe 6-7)"
echo "Symptoms: 40ms jitter with 'pipe 7' in ping tests during gaming"
echo "Root cause: Linux iwlwifi aggregates packets differently than Windows"
echo
echo "Current parameters:"
echo "11n_disable: $(cat /sys/module/iwlwifi/parameters/11n_disable 2>/dev/null)"
echo "amsdu_size: $(cat /sys/module/iwlwifi/parameters/amsdu_size 2>/dev/null)"
echo "uapsd_disable: $(cat /sys/module/iwlwifi/parameters/uapsd_disable 2>/dev/null)"
echo
echo "1) Apply packet batching fix    2) Restore defaults    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Applying Intel WiFi gaming rate fix..."
        
        # Check if already applied via modprobe config
        if grep -q "options iwlwifi" /etc/modprobe.d/iwlwifi.conf 2>/dev/null; then
            echo "Existing iwlwifi config found, backing up..."
            sudo cp /etc/modprobe.d/iwlwifi.conf /etc/modprobe.d/iwlwifi.conf.backup
        fi
        
        # Create/update iwlwifi configuration to disable packet batching
        sudo tee /etc/modprobe.d/iwlwifi.conf > /dev/null << 'EOF'
# Intel WiFi packet batching fix for gaming
# Disables aggregation that causes "pipe 6-7" behavior and 40ms jitter
options iwlwifi 11n_disable=8 amsdu_size=1 uapsd_disable=1 power_save=0 bt_coex_active=0
EOF
        
        echo "✓ Gaming rate fix configuration applied"
        echo "✓ Will take effect after WiFi driver reload or reboot"
        echo
        echo "To apply immediately (will disconnect WiFi briefly):"
        echo "sudo modprobe -r iwlwifi && sudo modprobe iwlwifi"
        ;;
    2)
        echo "Restoring Intel WiFi default settings..."
        
        # Remove current config file
        if [ -f /etc/modprobe.d/iwlwifi.conf ]; then
            sudo rm -f /etc/modprobe.d/iwlwifi.conf
        fi
        
        # Restore backup if it exists (original user config)
        if [ -f /etc/modprobe.d/iwlwifi.conf.backup ]; then
            sudo mv /etc/modprobe.d/iwlwifi.conf.backup /etc/modprobe.d/iwlwifi.conf
            echo "✓ Original iwlwifi config restored"
        else
            echo "✓ iwlwifi config removed - back to kernel defaults"
        fi
        
        echo "✓ Default settings restored"
        echo "✓ Will take effect after WiFi driver reload or reboot"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
