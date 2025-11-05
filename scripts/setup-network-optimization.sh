#!/bin/bash

# Essential network optimization - non-interactive from main orchestrator
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Applying network optimizations..."

if ! echo "1" | bash "$SCRIPT_DIR/../fixes/install-wireless-regdb.sh"; then
    echo "Failed to apply wireless-regdb fix"
fi

if ! echo "1" | bash "$SCRIPT_DIR/../fixes/wifi-power-management.sh"; then
    echo "Failed to apply WiFi power management fix"
fi

if ! echo "1" | bash "$SCRIPT_DIR/../fixes/irqbalance_fix.sh"; then
    echo "Failed to apply IRQ balance fix"
fi

if ! echo "1" | bash "$SCRIPT_DIR/../fixes/buffer_bloat_fix.sh"; then
    echo "Failed to apply buffer bloat fix"
fi

echo "Network optimization complete"
