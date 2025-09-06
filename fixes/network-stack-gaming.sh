#!/bin/bash

# Network Stack Gaming Fix - Ultra-low latency network stack optimizations

echo "=== Network Stack Gaming Fix ==="
echo "Problem: Default Linux network stack may batch packets for efficiency"
echo "Solution: Optimize for ultra-low latency at the cost of throughput"
echo
echo "Current settings:"
echo "netdev_max_backlog: $(sysctl -n net.core.netdev_max_backlog)"
echo "netdev_budget: $(sysctl -n net.core.netdev_budget)"
echo "dev_weight: $(sysctl -n net.core.dev_weight)"
echo
echo "1) Apply ultra-low latency settings    2) Restore defaults    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Applying ultra-low latency network stack settings..."
        
        # Reduce network device queue backlog (less batching)
        echo 100 | sudo tee /proc/sys/net/core/netdev_max_backlog > /dev/null
        
        # Reduce network budget per poll (process packets more frequently)
        echo 50 | sudo tee /proc/sys/net/core/netdev_budget > /dev/null
        
        # Reduce device weight (less work per poll cycle)
        echo 16 | sudo tee /proc/sys/net/core/dev_weight > /dev/null
        
        # Disable network device offloading that can cause latency
        ethtool -K wlan0 gro off 2>/dev/null || echo "GRO disable failed (may not be supported)"
        ethtool -K wlan0 gso off 2>/dev/null || echo "GSO disable failed (may not be supported)"
        
        # Create sysctl config for persistence
        sudo tee /etc/sysctl.d/99-gaming-network.conf > /dev/null << 'EOF'
# Ultra-low latency network stack for gaming
net.core.netdev_max_backlog = 100
net.core.netdev_budget = 50
net.core.dev_weight = 16

# Additional UDP optimizations for gaming
net.core.rmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_default = 262144
net.core.wmem_max = 16777216

# Reduce network latency
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_timestamps = 0
EOF
        
        # Apply sysctl settings
        sudo sysctl -p /etc/sysctl.d/99-gaming-network.conf
        
        echo "✓ Ultra-low latency network settings applied"
        echo "✓ Settings will persist across reboots"
        echo
        echo "New settings:"
        echo "netdev_max_backlog: $(sysctl -n net.core.netdev_max_backlog)"
        echo "netdev_budget: $(sysctl -n net.core.netdev_budget)"  
        echo "dev_weight: $(sysctl -n net.core.dev_weight)"
        ;;
    2)
        echo "Restoring default network stack settings..."
        
        # Remove custom sysctl config
        sudo rm -f /etc/sysctl.d/99-gaming-network.conf
        
        # Restore ACTUAL Arch Linux defaults (verified from current system)
        echo 1000 | sudo tee /proc/sys/net/core/netdev_max_backlog > /dev/null
        echo 300 | sudo tee /proc/sys/net/core/netdev_budget > /dev/null  
        echo 64 | sudo tee /proc/sys/net/core/dev_weight > /dev/null
        echo 212992 | sudo tee /proc/sys/net/core/rmem_max > /dev/null
        echo 212992 | sudo tee /proc/sys/net/core/wmem_max > /dev/null
        echo 0 | sudo tee /proc/sys/net/ipv4/tcp_low_latency > /dev/null
        
        # Re-enable offloading
        ethtool -K wlan0 gro on 2>/dev/null || echo "GRO enable failed (may not be supported)"
        ethtool -K wlan0 gso on 2>/dev/null || echo "GSO enable failed (may not be supported)"
        
        echo "✓ Default network settings restored"
        echo
        echo "Current settings:"
        echo "netdev_max_backlog: $(sysctl -n net.core.netdev_max_backlog)"
        echo "netdev_budget: $(sysctl -n net.core.netdev_budget)"
        echo "dev_weight: $(sysctl -n net.core.dev_weight)"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
