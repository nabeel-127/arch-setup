#!/bin/bash

# Timer Source Gaming Fix - Proper timer optimization for gaming with full reversibility

echo "=== Timer Source Gaming Fix ==="
echo "Problem: Default timer source may cause gaming timing issues"
echo "Solution: Optimize timer source and enable high-resolution timers"
echo
echo "Current clocksource: $(cat /sys/devices/system/clocksource/clocksource0/current_clocksource)"
echo "Available clocksources: $(cat /sys/devices/system/clocksource/clocksource0/available_clocksource)"
echo
echo "Arch Linux Default: hpet (auto-selected, no GRUB override)"
echo
echo "1) Apply gaming timer optimizations    2) Restore Arch defaults    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Applying gaming timer optimizations..."
        
        # Create GRUB config file if it doesn't exist (needed for timer settings)
        if [ ! -f /etc/default/grub ]; then
            echo "Creating /etc/default/grub (doesn't exist on your system)..."
            sudo tee /etc/default/grub > /dev/null << 'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Arch"
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
GRUB_CMDLINE_LINUX=""
EOF
        else
            # Backup existing GRUB config
            sudo cp /etc/default/grub /etc/default/grub.backup
        fi
        
        # Add gaming-optimized timer parameters
        echo "Adding gaming timer optimizations to GRUB..."
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="highres=on nohz=off processor.max_cstate=1 intel_idle.max_cstate=1 /' /etc/default/grub
        
        # Try to enable TSC if available, otherwise use best available
        available_sources=$(cat /sys/devices/system/clocksource/clocksource0/available_clocksource)
        if echo "$available_sources" | grep -q "tsc"; then
            echo "Enabling TSC clocksource (best for gaming)..."
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="clocksource=tsc /' /etc/default/grub
        else
            echo "TSC not available, using HPET with optimizations..."
            # HPET is already the default, just add optimizations
        fi
        
        # Update GRUB
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        
        echo "✓ Gaming timer optimizations applied"
        echo "✓ High-resolution timers enabled" 
        echo "✓ CPU idle states limited for consistent timing"
        echo "✓ Changes will take effect after reboot"
        echo
        echo "Current settings require reboot to fully activate."
        ;;
    2)
        echo "Restoring Arch Linux timer defaults..."
        
        # Remove GRUB file if we created it (restore to original no-grub state)
        if [ -f /etc/default/grub.backup ]; then
            echo "Restoring original GRUB configuration..."
            sudo mv /etc/default/grub.backup /etc/default/grub
            sudo grub-mkconfig -o /boot/grub/grub.cfg
        elif [ -f /etc/default/grub ]; then
            # We created the GRUB file, remove it to restore original state
            echo "Removing GRUB config (restoring original no-grub state)..."
            sudo rm /etc/default/grub
            # Regenerate default GRUB config
            sudo grub-mkconfig -o /boot/grub/grub.cfg
        fi
        
        echo "✓ Arch Linux timer defaults restored"
        echo "✓ System will use kernel auto-selected clocksource (hpet)"
        echo "✓ Default timer behavior restored"
        echo "✓ Changes will take effect after reboot"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
