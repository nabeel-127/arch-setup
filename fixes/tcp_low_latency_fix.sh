#!/bin/bash

# TCP Low Latency Fix - Enable low latency mode for gaming

echo "=== TCP Low Latency Fix ==="
echo "Current setting: $(cat /proc/sys/net/ipv4/tcp_low_latency)"
echo
echo "1) Enable low latency    2) Disable (default)    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Enabling TCP low latency..."
        echo 1 | sudo tee /proc/sys/net/ipv4/tcp_low_latency > /dev/null
        echo "✓ TCP low latency enabled"
        ;;
    2)
        echo "Disabling TCP low latency..."
        echo 0 | sudo tee /proc/sys/net/ipv4/tcp_low_latency > /dev/null
        echo "✓ TCP low latency disabled (default)"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
