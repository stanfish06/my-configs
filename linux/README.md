# Linux Setup Scripts

Modular, easy-to-use scripts for setting up a Linux development environment.

## Quick Start

```bash
# Run the full setup (installs everything)
./setup.sh full

# Install only what you need
./setup.sh basic          # Basic packages
./setup.sh languages      # All programming languages
./setup.sh languages python  # Just Python
```

## Available Commands
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

## Individual Script Usage

All scripts in the `setup/` and `system/` directories can be run independently:

```bash
# Install Neovim directly
./setup/neovim.sh

# Clean disk space
./system/clean-disk.sh

# Install a specific language
./setup/languages.sh python
```
