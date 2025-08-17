# Arch Linux Setup Automation

Clean, minimal scripts to streamline Arch Linux post-installation setup.

## Usage

```bash
# Make main script executable and run
chmod +x arch-install.sh
./arch-install.sh
```

The main script automatically makes all subscripts executable, so you only need to chmod the main file.

## Prerequisites

- Fresh Arch Linux installation
- User account with sudo privileges (member of wheel group)
- Internet connection

## Structure

```
arch-setup/
├── arch-install.sh            # Main orchestrator
├── scripts/                   # Installation scripts
│   ├── setup-package-stores.sh   # AUR helper (yay), Flatpak, Snap
│   ├── install-core-apps.sh      # Discord, Opera, ProtonMail, Notion
│   ├── setup-gaming.sh           # Steam, Gaming tools, Heroic
│   └── setup-ide.sh              # Development tools
└── utils/                     # Utility scripts
    └── setup-ssh.sh              # SSH key generation
```

## What Gets Installed

**Package Managers:**
- yay (AUR helper)
- Flatpak + Flathub
- Snap (optional)

**Core Apps:**
- Discord
- Opera
- ProtonMail Bridge
- Notion
- Firefox
- Essential utilities (htop, neofetch, tree, etc.)

**Gaming:**
- Steam (with multilib support)
- Heroic Games Launcher (Epic/GOG)
- Wine + Winetricks
- Vulkan drivers and tools
- GameMode (performance optimization)
- MangoHud (performance overlay)

**Development:**
- Essential build tools (base-devel)
- Git version control
- Node.js and npm
- Python and pip
- SSH keys for Git

## Installation Priority

1. Pacman (official Arch repositories)
2. AUR via yay (Arch User Repository)
3. Flatpak (for specific apps)
4. Snap (fallback for some apps)

## Notes

- NVIDIA drivers are not included as Arch maintains them in official repos
- Display scaling setup has been removed - configure manually in your DE
- No specific code editor is installed - add your preferred one manually

