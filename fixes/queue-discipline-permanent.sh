#!/bin/bash

# Queue Discipline Permanent Fix - Make fq_codel persistent via systemd

echo "=== Queue Discipline Permanent Fix ==="
echo "Current qdisc: $(tc qdisc show dev wlan0 | awk '{print $2}')"
echo
echo "Problem: fq_codel reverts to 'noqueue' after reboot/NetworkManager changes"
echo "Solution: Create systemd service to enforce fq_codel on wlan0"
echo
echo "1) Apply permanent fq_codel fix    2) Remove fix    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Creating permanent fq_codel fix..."
        
        # Create systemd service file
        sudo tee /etc/systemd/system/wifi-qdisc-fix.service > /dev/null << 'EOF'
[Unit]
Description=WiFi Queue Discipline Fix (fq_codel)
After=network.target
Wants=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'sleep 5 && tc qdisc replace dev wlan0 root fq_codel'
ExecReload=/bin/bash -c 'tc qdisc replace dev wlan0 root fq_codel'

[Install]
WantedBy=multi-user.target
EOF

        # Enable and start service
        sudo systemctl daemon-reload
        sudo systemctl enable wifi-qdisc-fix.service
        sudo systemctl start wifi-qdisc-fix.service
        
        # Apply fix immediately
        sudo tc qdisc replace dev wlan0 root fq_codel
        
        echo "✓ Permanent fq_codel fix applied"
        echo "New qdisc: $(tc qdisc show dev wlan0 | awk '{print $2}')"
        echo "Service status: $(systemctl is-active wifi-qdisc-fix.service)"
        ;;
    2)
        echo "Removing permanent fq_codel fix..."
        sudo systemctl stop wifi-qdisc-fix.service 2>/dev/null || true
        sudo systemctl disable wifi-qdisc-fix.service 2>/dev/null || true
        sudo rm -f /etc/systemd/system/wifi-qdisc-fix.service
        sudo systemctl daemon-reload
        echo "✓ Permanent fix removed"
        echo "Current qdisc: $(tc qdisc show dev wlan0 | awk '{print $2}')"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
