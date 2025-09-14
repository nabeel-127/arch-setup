#!/bin/bash

# Power Profile Gaming Fix - Use GNOME's official power management for gaming

echo "=== Power Profile Gaming Fix ==="
echo "Uses GNOME's official power-profiles-daemon (proper system integration)"
echo "Problem: Default 'balanced' profile may cause CPU frequency scaling during gaming"
echo "Solution: Switch to 'performance' profile for consistent gaming performance"
echo
echo "Available power profiles:"
powerprofilesctl list
echo
echo "Current active profile: $(powerprofilesctl get)"
echo "Current CPU governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
echo
echo "1) Switch to performance profile    2) Switch to balanced profile    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Switching to performance profile..."
        
        # Switch to performance using official GNOME system
        powerprofilesctl set performance
        
        # Verify the change
        new_profile=$(powerprofilesctl get)
        new_governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
        
        if [ "$new_profile" = "performance" ]; then
            echo "✓ Successfully switched to performance profile"
            echo "✓ Power profile: $new_profile"
            echo "✓ CPU governor: $new_governor"
            echo "✓ Changes are immediate and persistent"
            echo
            echo "⚠️  THERMAL WARNING: Performance profile increases CPU heat!"
            echo "Current temperature: $(sensors | grep Tctl | awk '{print $2}' 2>/dev/null || echo 'Unknown')"
            echo "NBFC thermal management: $(systemctl is-active nbfc_service 2>/dev/null || echo 'Not active')"
        else
            echo "❌ Failed to switch to performance profile"
            echo "Current profile: $new_profile"
        fi
        ;;
    2)
        echo "Switching to balanced profile..."
        
        # Switch to balanced (default) using official GNOME system
        powerprofilesctl set balanced
        
        # Verify the change
        new_profile=$(powerprofilesctl get)
        new_governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
        
        if [ "$new_profile" = "balanced" ]; then
            echo "✓ Successfully switched to balanced profile"
            echo "✓ Power profile: $new_profile" 
            echo "✓ CPU governor: $new_governor"
            echo "✓ Changes are immediate and persistent"
            echo "✓ System restored to default power management"
        else
            echo "❌ Failed to switch to balanced profile"
            echo "Current profile: $new_profile"
        fi
        ;;
    *)
        echo "Exiting..."
        ;;
esac
