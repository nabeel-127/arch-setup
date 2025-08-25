#!/bin/bash

# Network Buffer Optimization - Optimize buffer sizes for gaming

echo "=== Network Buffer Optimization ==="
echo "Current rmem_max: $(cat /proc/sys/net/core/rmem_max)"
echo "Current wmem_max: $(cat /proc/sys/net/core/wmem_max)"
echo
echo "1) Apply gaming buffers (16MB)    2) Revert to default    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Applying gaming buffer optimization..."
        echo 16777216 | sudo tee /proc/sys/net/core/rmem_max > /dev/null
        echo 16777216 | sudo tee /proc/sys/net/core/wmem_max > /dev/null
        echo 16777216 | sudo tee /proc/sys/net/core/rmem_default > /dev/null
        echo 16777216 | sudo tee /proc/sys/net/core/wmem_default > /dev/null
        echo "✓ Gaming buffers applied (16MB)"
        ;;
    2)
        echo "Reverting to default buffers..."
        echo 212992 | sudo tee /proc/sys/net/core/rmem_max > /dev/null
        echo 212992 | sudo tee /proc/sys/net/core/wmem_max > /dev/null
        echo 212992 | sudo tee /proc/sys/net/core/rmem_default > /dev/null
        echo 212992 | sudo tee /proc/sys/net/core/wmem_default > /dev/null
        echo "✓ Default buffers restored (208KB)"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
