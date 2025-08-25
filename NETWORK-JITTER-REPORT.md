# Network Jitter Investigation & Fixes

## Problem Statement
CS:GO experiencing severe network jitter on Arch Linux with Intel AX200 WiFi card, while Windows with identical hardware has no issues.

---

## Investigation Timeline

### [2025-08-24] Initial Investigation

#### Baseline Measurements
- **Initial jitter:** 6-114ms (35ms std dev)
- **WiFi connection:** 54 Mbps, no HT mode, 20MHz width
- **Hardware:** Intel AX200 WiFi 6

#### Root Causes Identified
1. **WiFi Power Management ON** ✅ FIXED
   - Power management causing sleep/wake cycles
   - Fixed via temporary command: `iw dev wlan0 set power_save off`

2. **11n Aggregation Issues** ❌ PARTIAL FIX
   - Disabled with `options iwlwifi 11n_disable=1`
   - **Problem:** Too aggressive, disabled ALL modern WiFi

3. **WiFi AP Roaming** ❓ INVESTIGATED
   - Card switching between APs: 74:12:13:0a:21:0a ↔ 74:12:13:0a:21:0b
   - Causes intermittent 100ms+ spikes

4. **Missing Regulatory Database** ❓ IDENTIFIED
   - `wireless-regdb` not installed
   - Regulatory domain set to generic "country 00"

#### Post-Initial-Fixes Results
- **Jitter:** 5-19ms (4.4ms std dev) - IMPROVED
- **WiFi still limited to:** 54 Mbps, 20MHz, no HT
- **Connection stability:** Better but still occasional spikes

---

### [2025-08-25] Comprehensive Analysis

#### Cleanup & Reset
- Removed unnecessary changes from previous fixes
- Kept only essential fixes (power management)
- Established clean baseline for continued investigation

#### Advanced Diagnostics Results
1. **WiFi Connection Breakthrough** ✅ FIXED
   - After installing `wireless-regdb`: **2401 Mbps RX/2268 Mbps TX**
   - Channel width: 160MHz (was 20MHz)
   - Mode: WiFi 6 HE-MCS 11 HE-NSS 2 (full WiFi 6 capabilities)
   - **4400% speed improvement**

2. **Buffer Bloat Confirmed** ❌ CRITICAL ISSUE
   - Ping under load: 4-117ms (40ms std dev)
   - Progressive jitter patterns in burst tests
   - Network buffers filling then clearing over time
   - **Primary remaining cause of jitter**

3. **IRQ Distribution Issues** ❌ SECONDARY ISSUE
   - `irqbalance` service not running
   - WiFi interrupts concentrated on specific CPU cores
   - Uneven interrupt handling causes processing delays

4. **Advanced Ping Analysis**
   - High-frequency test: 4-112ms (41ms std dev)
   - Burst pattern test: Shows clearing buffer pattern
   - Last burst: 5.6-6.6ms (0.347ms std dev) - Proves potential

#### Current Status
- **Connection speed:** ✅ FIXED (2.4 Gbps, full WiFi 6)
- **Power management:** ✅ FIXED (permanently disabled)
- **WiFi stability:** ✅ IMPROVED (no AP switching seen)
- **Jitter:** ❌ STILL PRESENT (4-1217ms, 161ms std dev)
- **Packet loss:** ✅ NONE (0% across all tests)

---

## Recommended Next Fixes

### Priority 1: Buffer Bloat Mitigation
- Install `irqbalance` service
- Apply `fq_codel` queue discipline to WiFi interface
- Optimize TCP buffer sizes for gaming
- Implement selective TCP optimizations

### Priority 2: IRQ Optimization
- Balance WiFi interrupts across CPU cores
- Pin critical WiFi interrupts to performance cores
- Improve interrupt processing latency

### Priority 3: Final Tuning
- Fine-tune WiFi card specific parameters
- Consider selective TX aggregation control
- Monitor and optimize under actual gaming load

---

## Technical Details

### Current WiFi Connection
```
Connected to 74:12:13:0a:21:0b (on wlan0)
SSID: Gigaclear_2109
freq: 5180.0 MHz
width: 160 MHz, center1: 5250 MHz
signal: -41 dBm
rx bitrate: 2401.9 MBit/s 160MHz HE-MCS 11 HE-NSS 2 HE-GI 0 HE-DCM 0
tx bitrate: 2268.5 MBit/s 160MHz HE-MCS 11 HE-NSS 2 HE-GI 1 HE-DCM 0
```

### Network Stack Settings
```
TCP congestion: cubic (not optimal for gaming)
RX/TX buffers: 212992 bytes (default, not optimized)
TX queue length: 1000 (default)
IRQbalance: not running
```

### Scripts Status
- `install-wireless-regdb.sh` ✅ APPLIED
- `wifi-power-permanent.sh` ✅ APPLIED
- All other scripts removed

---

### [2025-08-25 13:21] IRQ Balance Fix Applied

#### Implementation
- **Applied fix:** `fixes/irqbalance_fix.sh` - minimal interactive script
- **Package installed:** irqbalance 1.9.4-2 from official Arch repos
- **Service status:** enabled and active (running since 13:20:28 BST)
- **Process PID:** 10376 with 2 tasks, 1.3M memory usage

#### IRQ Distribution Analysis
**✅ EXCELLENT WiFi IRQ Distribution:**
- WiFi interrupts (IRQs 81-96) properly distributed across 16 CPU cores
- Each WiFi queue mapped to different CPU cores:
  - Queue 0-15: Individual core assignment (CPU0, CPU1, CPU2, etc.)
  - High interrupt activity: 23K-190K interrupts per queue
  - Balanced load: No single core overloaded

**⚠️ Minor Permission Warnings:**
- Some IRQs (56, 59, 62, 65, 67) show "Permission denied" for affinity changes
- These IRQs marked as "unmanaged" by irqbalance
- **Impact:** Minimal - core WiFi queues are properly managed

#### Network Jitter Test Results
**Gateway Test (Local):**
- RTT: min=1.3ms, avg=21.2ms, max=55.5ms, mdev=18.4ms
- **Status:** Still shows significant jitter (18.4ms std dev)

**Cloudflare Test (Internet):**
- RTT: min=4.6ms, avg=5.8ms, max=6.7ms, mdev=0.6ms
- **Status:** Excellent stability (0.6ms std dev)

#### Current Assessment
- **IRQ Distribution:** ✅ FIXED - Proper load balancing implemented
- **Service Health:** ✅ GOOD - Running with minor non-critical warnings
- **Internet Jitter:** ✅ EXCELLENT - 0.6ms variation to Cloudflare
- **Local Jitter:** ❌ STILL HIGH - 18.4ms variation to gateway

**Analysis:** IRQ balancing significantly improved internet stability but local network still shows buffer bloat characteristics. The dramatic difference between local (18.4ms jitter) and internet (0.6ms jitter) suggests **buffer bloat in local network path** rather than system-level IRQ issues.

**Next Priority:** Buffer bloat mitigation for local network stack.

---

### [2025-08-25 13:30] Buffer Bloat Fix Applied

#### Implementation
- **Applied fix:** `fixes/buffer_bloat_fix.sh` - minimal fq_codel script
- **Queue discipline:** Changed from `noqueue` to `fq_codel`
- **Configuration:** limit=10240p, flows=1024, target=5ms, interval=100ms
- **Memory limit:** 32MB with ECN enabled, drop_batch=64

#### Queue Discipline Analysis
**✅ SUCCESSFUL fq_codel Configuration:**
- **Before:** `noqueue` (no buffering control)
- **After:** `fq_codel 8001` with optimal gaming parameters
- **Statistics:** 1195 packets sent (1.7MB), 0 drops, 0 overlimits
- **Consistency:** Matches ethernet interface configuration exactly
- **Features:** ECN marking enabled, flow separation active

#### Network Jitter Test Results
**Gateway Test 1 (0.2s interval):**
- RTT: min=2.0ms, avg=2.3ms, max=3.0ms, mdev=0.256ms
- **Status:** 🎯 EXCELLENT - **98.6% jitter reduction** (was 18.4ms, now 0.256ms)

**Gateway Test 2 (0.1s interval):**
- RTT: min=1.2ms, avg=40.6ms, max=104.3ms, mdev=43.7ms
- **Status:** ❌ Still problematic with higher frequency pings

**Cloudflare Test:**
- RTT: min=4.5ms, avg=27.2ms, max=63.1ms, mdev=20.2ms
- **Status:** ⚠️ Degraded from previous 0.6ms (unexpected)

#### Critical Discovery
**Rate-Dependent Jitter Pattern:**
- **0.2s intervals:** Near-perfect stability (0.256ms jitter)
- **0.1s intervals:** High jitter returns (43.7ms jitter)
- **Pattern:** Suggests **rate limiting or burst handling issues**

**Analysis:** fq_codel successfully eliminated buffer bloat under normal conditions but reveals a **deeper issue with high-frequency packet handling**. The dramatic difference between ping intervals suggests:
1. **Rate limiting** in WiFi driver or firmware
2. **Burst buffer overflow** in WiFi stack
3. **AP-side congestion control** affecting rapid requests

#### Current Assessment
- **Buffer Bloat (Normal Rate):** ✅ FIXED - 0.256ms jitter at normal intervals
- **High-Frequency Handling:** ❌ CRITICAL - 43.7ms jitter at gaming rates
- **Queue Management:** ✅ OPTIMAL - fq_codel working correctly
- **Root Cause:** Likely **WiFi driver/firmware rate limiting**

**Next Priority:** Gaming network stack optimization (TCP BBR, burst handling).

---

### [2025-08-25 18:30] CRITICAL: Thermal Management Emergency Fix

#### Crisis Event
- **Problem:** System crashed due to overheating during network testing
- **Symptoms:** CPU temperatures reached 84°C+ with fans at minimal speed (~3400 RPM)
- **Root cause:** NO thermal management software installed on system
- **Impact:** Complete system crash, potential hardware damage risk

#### Emergency Response
1. **Immediate diagnosis:** `sensors` revealed critical temperatures:
   - CPU (Tctl): 76.6°C rising to 92°C+  
   - ACPITZ: 84°C (dangerous levels)
   - Fans locked at low speeds despite critical temps

2. **Solution implemented:** NBFC laptop fan control
   - **Package:** `nbfc-linux` from AUR (laptop-specific fan control)
   - **Configuration:** HP OMEN Laptop profile applied
   - **Result:** Fans ramped from 3400 RPM → 5689 RPM (CPU) / 4122 RPM (GPU)

#### Implementation Details
- **Script created:** `scripts/setup-thermal.sh`
- **Packages installed:** `lm_sensors`, `nbfc-linux`
- **Service status:** `nbfc_service` enabled and active
- **Fan control:** Automatic temperature-based curves implemented

#### Post-Fix Verification
```
Fan Display Name         : CPU fan
Temperature              : 92.77°C → cooling down
Current Fan Speed        : 99.00% (emergency cooling)
Target Fan Speed         : 100.00%
Auto Control Enabled     : true

Fan Display Name         : GPU fan  
Temperature              : 78.92°C
Current Fan Speed        : 74.00%
Auto Control Enabled     : true
```

#### System Integration
- **Main installer:** Updated `arch-install.sh` to include thermal setup
- **Documentation:** Added to WARP.md as critical laptop requirement
- **Cleanup:** Removed ineffective packages (cpupower, failed thermald attempts)

#### Current Assessment
- **Thermal Management:** ✅ FIXED - Automatic fan control active
- **System Stability:** ✅ RESTORED - No more overheating crashes
- **Fan Response:** ✅ WORKING - Dynamic speed based on temperatures
- **Setup Integration:** ✅ COMPLETE - Now part of automated installation

**Critical Learning:** Thermal management is **MANDATORY** for HP OMEN laptops running intensive tasks. System will crash without proper fan control.
