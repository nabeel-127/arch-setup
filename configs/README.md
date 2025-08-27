# Configuration Files

This directory contains custom configuration files used by the setup scripts.

## Thermal Profiles

### HP OMEN Laptop 15-en0xxx Aggressive.json

A custom NBFC (NoteBook FanControl) profile for HP OMEN laptops that provides more aggressive cooling than the default profile.

**Key Improvements:**
- Fans start at 40°C instead of 49°C
- Higher fan speeds at lower temperatures
- At 60°C: 45% fan speed (vs 24% in default profile)
- At 65°C: 55% fan speed (vs 24% in default profile)

**Usage:**
This profile is automatically installed and applied by `scripts/setup-thermal.sh`.

**Manual Installation:**
```bash
sudo cp "HP OMEN Laptop 15-en0xxx Aggressive.json" /usr/share/nbfc/configs/
sudo nbfc config --apply "HP OMEN Laptop 15-en0xxx Aggressive"
```

**Temperature Thresholds:**
| Temperature | Fan Speed | Notes |
|-------------|-----------|-------|
| 40°C        | 10%       | Early cooling starts |
| 50°C        | 25%       | Light workload |
| 55°C        | 35%       | Medium workload |
| 60°C        | 45%       | Heavy workload |
| 65°C        | 55%       | Gaming/intensive tasks |
| 70°C+       | 65-100%   | Maximum cooling |
