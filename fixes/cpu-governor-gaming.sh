#!/bin/bash

# CPU Governor Gaming Fix - Switch from powersave to performance for low latency

echo "=== CPU Governor Gaming Fix ==="
echo "Problem: powersave governor causes CPU frequency scaling during network bursts"
echo "Impact: Network processing delays contribute to jitter during sustained load"
echo
echo "⚠️  THERMAL WARNING: Performance governor increases CPU heat!"
echo "Current temperature: $(sensors | grep Tctl | awk '{print $2}' || echo 'Unknown')"
echo "NBFC thermal management: $(systemctl is-active nbfc_service || echo 'Not active')"
echo
echo "Current governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
echo "Available governors: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)"
echo
echo "1) Switch to performance governor    2) Switch to powersave    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Switching to performance governor for gaming..."
        
        # Switch all CPUs to performance governor
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            if [ -w "$cpu" ]; then
                echo performance | sudo tee "$cpu" > /dev/null
            fi
        done
        
        # Use cpupower if available for more comprehensive change
        if command -v cpupower >/dev/null 2>&1; then
            sudo cpupower frequency-set -g performance >/dev/null 2>&1
        fi
        
        echo "✓ Performance governor applied to all CPUs"
        echo "Current governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
        
        # Make it permanent with systemd service
        echo "Creating permanent CPU governor service..."
        sudo tee /etc/systemd/system/cpu-performance.service > /dev/null << 'EOF'
[Unit]
Description=CPU Performance Governor for Gaming
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/cpupower frequency-set -g performance
ExecStop=/usr/bin/cpupower frequency-set -g powersave

[Install]
WantedBy=multi-user.target
EOF
        
        # Enable and start the service
        sudo systemctl daemon-reload
        sudo systemctl enable cpu-performance.service
        sudo systemctl start cpu-performance.service
        
        echo "✓ Permanent CPU performance service created and enabled"
        echo "✓ Will persist across reboots"
        ;;
    2)
        echo "Switching to powersave governor..."
        
        # Switch all CPUs to powersave governor  
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            if [ -w "$cpu" ]; then
                echo powersave | sudo tee "$cpu" > /dev/null
            fi
        done
        
        # Use cpupower if available
        if command -v cpupower >/dev/null 2>&1; then
            sudo cpupower frequency-set -g powersave >/dev/null 2>&1
        fi
        
        # Remove permanent service  
        sudo systemctl stop cpu-performance.service 2>/dev/null || true
        sudo systemctl disable cpu-performance.service 2>/dev/null || true
        sudo rm -f /etc/systemd/system/cpu-performance.service
        sudo systemctl daemon-reload
        
        # Switch to powersave governor
        sudo cpupower frequency-set -g powersave
        
        echo "✓ Permanent performance service removed"
        echo "✓ Powersave governor applied to all CPUs"
        echo "Current governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
