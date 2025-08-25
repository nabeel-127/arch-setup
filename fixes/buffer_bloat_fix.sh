#!/bin/bash

# Buffer Bloat Fix - Minimal script for network jitter reduction

echo "=== Buffer Bloat Fix ==="
echo "Current qdisc: $(tc qdisc show dev wlan0 | awk '{print $2}')"
echo "System default: $(cat /proc/sys/net/core/default_qdisc)"
echo
echo "1) Apply fix (fq_codel)    2) Revert fix (system default)    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Applying fq_codel to wlan0..."
        sudo tc qdisc replace dev wlan0 root fq_codel
        echo "✓ fq_codel enabled"
        ;;
    2)
        echo "Reverting to system default..."
        sudo tc qdisc del dev wlan0 root 2>/dev/null || true
        echo "✓ Reverted to system default ($(cat /proc/sys/net/core/default_qdisc))"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
