# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Common Commands

### Main Installation
```bash
# Make main script executable and run complete setup
chmod +x arch-install.sh
./arch-install.sh
```

### Individual Component Setup
```bash
# Setup package managers (yay, Flatpak)
bash scripts/setup-package-stores.sh

# Install core applications (Discord, Firefox, Opera, etc.)
bash scripts/install-core-apps.sh

# Setup gaming environment (Steam, Wine, Heroic)
bash scripts/setup-gaming.sh

# Setup development tools (Node.js, Python, build tools)
bash scripts/setup-ide.sh

# Generate SSH keys for Git
bash utils/setup-ssh.sh
```

### Testing and Validation
```bash
# Check if key tools are installed
command -v yay && echo "yay installed" || echo "yay missing"
command -v flatpak && echo "flatpak installed" || echo "flatpak missing"
command -v steam && echo "steam installed" || echo "steam missing"

# Verify multilib repository is enabled (required for gaming)
grep -q "\[multilib\]" /etc/pacman.conf && echo "multilib enabled" || echo "multilib disabled"

# Test script syntax without execution
bash -n scripts/setup-package-stores.sh
bash -n scripts/install-core-apps.sh
bash -n scripts/setup-gaming.sh
bash -n scripts/setup-ide.sh
bash -n utils/setup-ssh.sh
```

### Development Workflow
```bash
# Make all scripts executable after modifications
chmod +x scripts/*.sh utils/*.sh

# Test individual scripts in isolation
bash -x scripts/setup-package-stores.sh  # Run with debug output
```

## Code Architecture

### High-Level Structure
This is a modular Arch Linux post-installation automation system designed around bash scripts that follow a specific execution order and dependency chain.

### Core Components

**Main Orchestrator (`arch-install.sh`)**
- Entry point that coordinates all setup phases
- Implements error handling with `set -e` and trap mechanisms
- Manages sudo timeout extension to prevent repeated password prompts
- Executes scripts in dependency order: package-managers → core-apps → gaming → ssh → development

**Package Management Layer (`scripts/setup-package-stores.sh`)**
- Establishes the foundation by installing base-devel and git
- Bootstraps yay (AUR helper) from source using makepkg
- Configures Flatpak with Flathub repository
- Creates three-tier package management: pacman → yay → flatpak

**Application Installation Scripts**
- Each script handles a specific domain (core apps, gaming, development)
- Implements graceful failure handling - continues on non-critical failures
- Uses package-specific installation strategies (pacman for official, yay for AUR, flatpak for sandboxed apps)

**Gaming Setup (`scripts/setup-gaming.sh`)**
- Critical system modification: enables multilib repository in `/etc/pacman.conf`
- Installs 32-bit compatibility libraries required by Steam
- Handles both native and compatibility layers (Wine, Vulkan, GameMode)

**Development Environment (`scripts/setup-ide.sh`)**
- Minimal approach - installs essential runtime tools (Node.js, Python)
- Deliberately avoids opinionated editor choices
- Relies on base-devel already installed by package-stores script

### Error Handling Strategy
- All scripts use `set -e` for immediate exit on any command failure
- Main orchestrator includes line-number error reporting
- Individual scripts implement conditional installation with failure messages
- Non-critical failures are logged but don't halt the entire process

### Security Considerations
- Temporary sudo timeout extension (60 minutes) with automatic cleanup
- Uses official installation methods (makepkg for yay, not pre-compiled binaries)
- PGP verification skipping only for known binary packages (Opera)
- SSH key generation follows modern practices (ed25519)

### Dependencies and Execution Order
The script execution order is critical due to dependencies:
1. **setup-package-stores.sh** - Must run first (installs base-devel, git, yay)
2. **install-core-apps.sh** - Depends on yay and flatpak from step 1
3. **setup-gaming.sh** - Modifies system configuration (multilib), depends on package managers
4. **setup-ssh.sh** - Independent utility, can run anytime after git is available
5. **setup-ide.sh** - Depends on base-devel from step 1

### Key Design Principles
- **Idempotent operations**: Scripts check for existing installations before proceeding
- **Package manager hierarchy**: Prefers pacman → yay → flatpak in that order
- **Graceful degradation**: Non-critical package failures don't halt the process
- **Clean temporary files**: All scripts clean up after themselves (especially yay installation)
- **User interaction**: Minimal prompts (only SSH email), mostly automated
