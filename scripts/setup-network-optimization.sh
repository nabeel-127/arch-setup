#!/bin/bash

# Essential network optimization - calls proven fixes from fixes/ directory

set -e

echo "=== Network Optimization Setup ==="
echo "This applies proven fixes for WiFi jitter and performance"
echo
echo "1) Apply network optimizations (wireless-regdb, irqbalance, wifi power management)"
echo "2) Skip network optimization"
read -p "Choice [1-2]: " choice

if [ "$choice" = "1" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    echo "Applying wireless regulatory database fix..."
    echo "1" | bash "$SCRIPT_DIR/../fixes/install-wireless-regdb.sh"
    
    echo "Applying WiFi power management fix..."
    echo "1" | bash "$SCRIPT_DIR/../fixes/wifi-power-management.sh"
    
    echo "Applying IRQ balance fix..."
    echo "1" | bash "$SCRIPT_DIR/../fixes/irqbalance_fix.sh"
    
    echo "Applying buffer bloat fix..."
    echo "1" | bash "$SCRIPT_DIR/../fixes/buffer_bloat_fix.sh"
    
    echo "✓ Network optimization complete"
else
    echo "Skipping network optimization"
fi
