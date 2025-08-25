#!/bin/bash

# BBR Congestion Control Fix - Enable BBR for gaming performance

echo "=== BBR Congestion Control Fix ==="
echo "Current: $(cat /proc/sys/net/ipv4/tcp_congestion_control)"
echo "Available: $(cat /proc/sys/net/ipv4/tcp_available_congestion_control)"
echo
echo "1) Enable BBR    2) Revert to CUBIC    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Enabling BBR..."
        sudo modprobe tcp_bbr
        echo bbr | sudo tee /proc/sys/net/ipv4/tcp_congestion_control > /dev/null
        echo "✓ BBR congestion control enabled"
        ;;
    2)
        echo "Reverting to CUBIC..."
        echo cubic | sudo tee /proc/sys/net/ipv4/tcp_congestion_control > /dev/null
        echo "✓ CUBIC congestion control restored"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
