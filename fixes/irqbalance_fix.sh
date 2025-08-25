#!/bin/bash

# IRQ Balance Fix - Minimal script for network jitter reduction

echo "=== IRQ Balance Fix ==="
echo "Current status: $(systemctl is-active irqbalance 2>/dev/null || echo 'not running')"
echo
echo "1) Apply fix    2) Revert fix    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Applying fix..."
        sudo pacman -S --noconfirm irqbalance
        sudo systemctl enable --now irqbalance
        echo "✓ IRQ balance enabled"
        ;;
    2)
        echo "Reverting fix..."
        sudo systemctl disable --now irqbalance 2>/dev/null || true
        sudo pacman -Rns --noconfirm irqbalance 2>/dev/null || true
        echo "✓ IRQ balance removed"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
