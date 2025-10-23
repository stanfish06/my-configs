# Linux Setup Scripts

Modular, easy-to-use scripts for setting up a Linux development environment.

## 🚀 Quick Start

```bash
# Run the full setup (installs everything)
./setup.sh full

# Install only what you need
./setup.sh basic          # Basic packages
./setup.sh languages      # All programming languages
./setup.sh languages python  # Just Python
```

## 📁 Directory Structure

```
linux/
├── setup.sh              # Main entry point script
├── lib/                  # Shared libraries and functions
│   └── common.sh        # Common utilities (colors, package managers, etc.)
├── setup/               # Installation scripts
│   ├── basic-packages.sh   # Essential tools (git, curl, build-essential, etc.)
│   ├── neovim.sh          # Neovim editor
│   ├── wezterm.sh         # WezTerm terminal
│   ├── oh-my-zsh.sh       # Oh My Zsh shell framework
│   ├── languages.sh       # Programming languages (Python, Node.js, etc.)
│   ├── libraries.sh       # Development libraries
│   ├── i3status.sh        # i3status bar
│   └── raylib.sh          # Raylib game library
├── system/              # System maintenance scripts
│   ├── clean-disk.sh      # Disk cleanup utility
│   └── update-network.sh  # Network DNS configuration
└── tools/               # Utility scripts
    └── fzf-preview.sh     # FZF file preview script
```

## 📋 Available Commands

### Main Setup Script

```bash
./setup.sh [COMMAND] [OPTIONS]
```

### Commands

| Command | Description | Example |
|---------|-------------|---------|
| `full` | Install everything | `./setup.sh full` |
| `basic` | Install basic packages | `./setup.sh basic` |
| `editor` | Install Neovim | `./setup.sh editor` |
| `terminal` | Install WezTerm | `./setup.sh terminal` |
| `shell` | Install Oh My Zsh | `./setup.sh shell` |
| `languages [LANG]` | Install programming languages | `./setup.sh languages python` |
| `libraries [LIB]` | Install development libraries | `./setup.sh libraries x11` |
| `i3status` | Install i3status | `./setup.sh i3status` |
| `raylib` | Install Raylib | `./setup.sh raylib` |
| `clean` | Clean disk space | `./setup.sh clean` |
| `help` | Show help | `./setup.sh help` |

### Language Options

```bash
# Install all languages
./setup.sh languages

# Install specific language
./setup.sh languages [python|nodejs|r|java|rust|julia|go]
```

**Supported Languages:**
- Python 3 (with pip and venv)
- Node.js (with npm)
- R (with base packages)
- Java (JRE and JDK)
- Rust (via rustup)
- Julia (via juliaup)
- Go

### Library Options

```bash
# Install all libraries
./setup.sh libraries

# Install specific library group
./setup.sh libraries [x11|math]
```

**Library Groups:**
- `x11`: X11 development libraries (libx11-dev, libxinerama-dev, libxft-dev)
- `math`: Math libraries (libopenblas-dev, libsuitesparse-dev)

## 🔧 Individual Script Usage

All scripts in the `setup/` and `system/` directories can be run independently:

```bash
# Install Neovim directly
./setup/neovim.sh

# Clean disk space
./system/clean-disk.sh

# Install a specific language
./setup/languages.sh python
```

## 📦 What Gets Installed

### Basic Packages (`basic`)
- curl, git, build-essential
- net-tools, zsh, tmux
- fd-find, fzf

### Editor (`editor`)
- Neovim (latest version from GitHub releases)
- Installed to `/opt/nvim-linux-x86_64`

### Terminal (`terminal`)
- WezTerm (nightly build)

### Shell (`shell`)
- Oh My Zsh with default plugins

### Languages (`languages`)
See language options above for full list.

### Libraries (`libraries`)
Development libraries for X11 and mathematical computations.

## 🎯 Features

- **Modular**: Install only what you need
- **Reusable**: Scripts can be run independently or sourced
- **Cross-distro**: Supports apt, pacman, and dnf package managers
- **Idempotent**: Safe to run multiple times
- **Color-coded output**: Easy to follow progress
- **Error handling**: Scripts exit on error for safety

## 🛠️ Maintenance

### Clean Disk Space

```bash
./setup.sh clean
```

This removes:
- User cache (~/.cache/)
- Old journal logs (keeps last 7 days)
- Package manager cache
- Unused packages

### Update Network DNS

```bash
./system/update-network.sh
```

Adds Google DNS (8.8.8.8) and Cloudflare DNS (1.1.1.1) to `/etc/resolv.conf`.

## 📝 Notes

- Most scripts require `sudo` access for package installation
- Language installers (Rust, Julia, Go) will add environment variables to your PATH
- After running setup, restart your shell or source your shell configuration file
- Scripts detect your package manager automatically (apt, pacman, or dnf)

## 🔍 Troubleshooting

### Script fails with "Permission denied"

Make sure scripts are executable:
```bash
chmod +x setup.sh
chmod +x -R setup/ system/ lib/
```

### Package not found

Update your package manager first:
```bash
# For apt
sudo apt update

# For pacman
sudo pacman -Sy

# For dnf
sudo dnf check-update
```

### "This script should NOT be run as root"

Some scripts (like language installers) should be run as a regular user, not with sudo.

## 🤝 Contributing

These are personal configuration scripts. Feel free to fork and adapt them to your needs.

## 📄 Legacy Scripts

The following original scripts are preserved in the root directory:
- `linux-setup.sh` - Original monolithic setup (now replaced by modular `setup.sh`)
- `install-*.sh` - Individual installers (now in `setup/` directory)
- `clean-disk.sh`, `update-network.sh` - Now in `system/` directory
- `fzf-preview.sh` - Now in `tools/` directory

These can be removed once you've verified the new modular structure works for your needs.
