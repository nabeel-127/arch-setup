# Network Jitter Analysis & Fixes for Gaming

## Problem Summary
CS:GO experiencing severe network jitter with ping times ranging from 6ms to 114ms (35ms standard deviation), making competitive gaming impossible.

## Root Cause Analysis

### Primary Issues Identified

1. **WiFi Power Management ON** ✅ FIXED
   - **Cause:** WiFi card enters sleep mode causing 100ms+ spikes
   - **Detection:** `iw dev wlan0 get power_save` showed "on"
   - **Fix:** Disabled via wifi-power-management.sh

2. **Overly Aggressive 11n Disable** ❌ NEEDS FIX
   - **Cause:** `11n_disable=1` disabled ALL modern WiFi (n/ac/ax)
   - **Impact:** Forced fallback to legacy 802.11a (54 Mbps max)
   - **Detection:** `iw dev wlan0 info` shows "width: 20 MHz (no HT)"
   - **Fix:** Use selective disable (disable aggregation only, not all 11n)

3. **WiFi Access Point Roaming** ❌ NEEDS FIX
   - **Cause:** Card switching between APs: 74:12:13:0a:21:0a ↔ 74:12:13:0a:21:0b
   - **Impact:** 100ms+ spikes during AP handover
   - **Detection:** dmesg shows frequent "disconnect from AP" messages
   - **Fix:** Disable roaming/band steering in NetworkManager

4. **Network Stack Not Optimized** ❌ NEEDS FIX
   - **Cause:** Default cubic congestion control, small buffers
   - **Impact:** Additional latency under load
   - **Detection:** sysctl shows cubic, netdev_max_backlog=1000
   - **Fix:** Switch to BBR, increase buffers, optimize for gaming

### Secondary Issues

5. **Driver HE Capability Warning**
   - **Detection:** dmesg shows "WARNING: CPU: 11 PID: 604 at iwl_init_he_hw_capab"
   - **Impact:** WiFi 6 features may not work optimally
   - **Fix:** Update driver parameters

6. **High Packet Retry/Drop Rate**
   - **Detection:** 4873 tx retries, 400 rx drops in station dump
   - **Impact:** Indicates poor RF conditions
   - **Fix:** Address via AP roaming fix and power management

## Performance Metrics

| State | Min Ping | Max Ping | Std Dev | Status |
|-------|----------|----------|---------|---------|
| Original | 6ms | 114ms | 35ms | ❌ Unplayable |
| Power Mgmt OFF + Bad 11n | 5ms | 19ms | 4.4ms | ⚠️ Improved but unstable |
| Target (All fixes) | 4ms | 8ms | <2ms | ✅ Gaming ready |

## Fix Implementation Order

### Immediate Fixes (Applied)
1. ✅ **WiFi Power Management OFF** - `./fixes/wifi-power-management.sh` (option 1)

### Critical Fixes Needed
2. **Correct 11n Settings** - Fix aggregation-toggle script  
3. **Disable WiFi Roaming** - Create roaming disable script
4. **Network Stack Optimization** - Create TCP/networking optimization script

### Optional Optimizations  
5. **Driver Parameter Tuning** - Advanced iwlwifi parameter optimization
6. **IRQ Affinity** - Pin WiFi interrupts to specific CPU core

## Technical Details

### WiFi Connection Analysis
- **Card:** Intel AX200 WiFi 6 (PCI ID: 0000:03:00.0)
- **Current Rate:** 54.0 Mbps (both TX/RX) - **TOO LOW!**
- **Expected Rate:** 400+ Mbps (WiFi 6 with proper settings)
- **Signal:** -44 to -46 dBm (adequate)
- **Channel:** 36 (5180 MHz) with 20 MHz width only

### Driver Parameters Status
```bash
iwlwifi parameters:
- power_save: N (disabled) ✅
- 11n_disable: 1 (ALL 11n disabled) ❌ TOO AGGRESSIVE
- uapsd_disable: 3 (disabled) ✅  
- disable_11ax: N (WiFi 6 enabled) ✅
- swcrypto: 0 (hardware crypto) ✅
```

### Network Stack Status
```bash
sysctl settings:
- tcp_congestion_control: cubic (should be bbr)
- netdev_max_backlog: 1000 (should be 5000+)
- tcp_timestamps: 1 (adds overhead)
```

## Next Steps

1. **Fix wifi-aggregation-toggle.sh** - Change from full disable to selective
2. **Create wifi-roaming-disable.sh** - Stop AP switching 
3. **Create network-stack-optimize.sh** - BBR + buffer optimization
4. **Test each fix individually** - Measure ping improvement
5. **Combine all fixes** - Achieve <2ms jitter target

## Commands for Verification

```bash
# Check power save status
iw dev wlan0 get power_save

# Check connection details  
iw dev wlan0 info
iw dev wlan0 link

# Monitor for AP switching
sudo dmesg -w | grep wlan0

# Test network performance
ping -c 50 -i 0.1 8.8.8.8
```
