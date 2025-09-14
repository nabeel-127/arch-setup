#!/bin/bash

# Clocksource Switch - Clean runtime switching using Linux's built-in interface

echo "=== Clocksource Switch ==="
echo "Uses Linux's native /sys interface - no custom configs"
echo

current=$(cat /sys/devices/system/clocksource/clocksource0/current_clocksource)
available=$(cat /sys/devices/system/clocksource/clocksource0/available_clocksource)

echo "Current clocksource: $current"
echo "Available clocksources: $available"
echo

echo "1) Switch to TSC (Time Stamp Counter - gaming optimized)"
echo "2) Switch to HPET (Hardware Platform Event Timer - stable)"
echo "3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        if [[ "$available" == *"tsc"* ]]; then
            echo "Switching to TSC clocksource..."
            echo "tsc" | sudo tee /sys/devices/system/clocksource/clocksource0/current_clocksource > /dev/null
            new_source=$(cat /sys/devices/system/clocksource/clocksource0/current_clocksource)
            if [ "$new_source" = "tsc" ]; then
                echo "✓ Successfully switched to TSC"
                echo "✓ TSC provides high-precision timing for gaming"
            else
                echo "❌ Failed to switch to TSC"
                echo "Current: $new_source"
            fi
        else
            echo "❌ TSC not available on this system"
            echo "Available: $available"
        fi
        ;;
    2)
        if [[ "$available" == *"hpet"* ]]; then
            echo "Switching to HPET clocksource..."
            echo "hpet" | sudo tee /sys/devices/system/clocksource/clocksource0/current_clocksource > /dev/null
            new_source=$(cat /sys/devices/system/clocksource/clocksource0/current_clocksource)
            if [ "$new_source" = "hpet" ]; then
                echo "✓ Successfully switched to HPET"
                echo "✓ HPET provides stable system timing"
            else
                echo "❌ Failed to switch to HPET"
                echo "Current: $new_source"
            fi
        else
            echo "❌ HPET not available on this system"
            echo "Available: $available"
        fi
        ;;
    *)
        echo "Exiting..."
        ;;
esac

echo
echo "Final clocksource: $(cat /sys/devices/system/clocksource/clocksource0/current_clocksource)"
