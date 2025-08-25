#!/bin/bash

# CPUPower Thermal Management - AMD CPU frequency and thermal control

echo "=== CPUPower Thermal Management ==="
echo "Current governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'unknown')"
echo "Package status: $(pacman -Q cpupower 2>/dev/null || echo 'not installed')"
echo
echo "1) Install cpupower + enable performance    2) Remove cpupower    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Installing cpupower..."
        sudo pacman -S --noconfirm cpupower
        echo "Setting performance governor for gaming..."
        sudo cpupower frequency-set -g performance
        echo "✓ CPUPower installed and performance mode enabled"
        ;;
    2)
        echo "Removing cpupower..."
        sudo cpupower frequency-set -g powersave 2>/dev/null || true
        sudo pacman -Rns --noconfirm cpupower 2>/dev/null || true
        echo "✓ CPUPower removed, reverted to powersave"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
