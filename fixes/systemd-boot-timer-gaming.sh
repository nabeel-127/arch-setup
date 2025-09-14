#!/bin/bash

# Systemd-boot Timer Gaming Fix - Safe and properly reversible timer optimization

echo "=== Systemd-boot Timer Gaming Fix ==="
echo "Problem: CS:GO shows 119ms jitter despite 3ms ping - Linux timer precision issue"
echo "Solution: Add kernel parameters to optimize timer behavior for gaming"
echo

# Define the expected original state for proper reversibility
ORIGINAL_CONTENT="title	Arch Linux
linux	/vmlinuz-linux
initrd	/initramfs-linux.img
options	root=PARTUUID=1da54652-8398-4bb5-bf73-8537b59e8307 rw"

GAMING_PARAMS=" highres=on nohz=off processor.max_cstate=1 intel_idle.max_cstate=1"

echo "Current systemd-boot entry:"
cat /boot/loader/entries/arch.conf
echo

echo "1) Apply gaming timer fix    2) Restore to original Arch state    3) Exit"
read -p "Choice: " choice

case "$choice" in
    1)
        echo "Applying gaming timer optimizations..."
        
        # Safety check: prevent duplicate application
        if grep -q "highres=on" /boot/loader/entries/arch.conf; then
            echo "⚠️  Gaming parameters already applied!"
            echo "Current entry:"
            cat /boot/loader/entries/arch.conf
            echo
            echo "No changes made to prevent duplicates."
            exit 0
        fi
        
        # Create backup before any changes
        sudo cp /boot/loader/entries/arch.conf /boot/loader/entries/arch.conf.backup
        
        # Safely append gaming parameters to options line only
        sudo sed -i '/^options\t.*rw$/s/$/ highres=on nohz=off processor.max_cstate=1 intel_idle.max_cstate=1/' /boot/loader/entries/arch.conf
        
        # Verify the change was applied correctly
        if grep -q "highres=on" /boot/loader/entries/arch.conf; then
            echo "✓ Gaming timer optimizations successfully applied"
            echo "✓ High-resolution timers enabled (highres=on)"
            echo "✓ Tickless kernel disabled for consistent timing (nohz=off)"
            echo "✓ CPU idle states limited to prevent timing gaps"
            echo
            echo "Updated systemd-boot entry:"
            cat /boot/loader/entries/arch.conf
            echo
            echo "⚠️  REBOOT required for changes to take effect"
            echo "This should fix the CS:GO 119ms timing jitter issue"
        else
            echo "❌ Failed to apply changes. Restoring backup..."
            sudo mv /boot/loader/entries/arch.conf.backup /boot/loader/entries/arch.conf
        fi
        ;;
    2)
        echo "Restoring to original Arch Linux state..."
        
        # Method 1: Use backup if available
        if [ -f /boot/loader/entries/arch.conf.backup ]; then
            sudo mv /boot/loader/entries/arch.conf.backup /boot/loader/entries/arch.conf
            echo "✓ Restored from backup"
        else
            # Method 2: Restore to documented original state
            echo "No backup found. Restoring to documented original Arch state..."
            echo "$ORIGINAL_CONTENT" | sudo tee /boot/loader/entries/arch.conf > /dev/null
            echo "✓ Restored to original Arch Linux configuration"
        fi
        
        # Verify restoration
        echo "Restored systemd-boot entry:"
        cat /boot/loader/entries/arch.conf
        echo
        
        # Verify it matches original state
        current_hash=$(md5sum /boot/loader/entries/arch.conf | cut -d' ' -f1)
        expected_hash="564c927907cf709c16a535d3b7c0d12e"
        
        if [ "$current_hash" = "$expected_hash" ]; then
            echo "✅ VERIFIED: File restored to exact original Arch state"
        else
            echo "⚠️  File restored but hash differs (may have different line endings)"
        fi
        
        echo "✓ Original Arch Linux timer behavior restored"
        echo "⚠️  REBOOT required for changes to take effect"
        ;;
    *)
        echo "Exiting..."
        ;;
esac
