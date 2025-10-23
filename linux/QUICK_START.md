# Quick Start Guide

Get up and running with the Linux setup scripts in minutes.

## 🎯 Common Use Cases

### First Time Setup (New Machine)

```bash
cd /path/to/my-configs/linux
./setup.sh full
```

This installs:
- Basic packages (git, curl, build-essential, etc.)
- Oh My Zsh
- Neovim
- WezTerm terminal
- All programming languages
- Development libraries

**Time required:** 15-30 minutes depending on internet speed

---

### Minimal Developer Setup

```bash
./setup.sh basic
./setup.sh editor
./setup.sh languages python nodejs
```

This installs:
- Essential tools
- Neovim text editor  
- Python and Node.js

**Time required:** 5-10 minutes

---

### Add a New Language

```bash
# Add Rust
./setup.sh languages rust

# Add Go
./setup.sh languages go

# Add multiple languages
./setup.sh languages python rust go
```

---

### Update Your System

```bash
# Clean up old packages and cache
./setup.sh clean
```

---

## 📖 Understanding the Commands

### Main Script

```bash
./setup.sh [command] [options]
```

### Available Commands

- `full` - Complete setup (everything)
- `basic` - Essential packages only
- `editor` - Neovim text editor
- `terminal` - WezTerm terminal
- `shell` - Oh My Zsh
- `languages [lang]` - Programming languages
- `libraries [lib]` - Development libraries
- `i3status` - i3 status bar
- `raylib` - Game development library
- `clean` - Clean disk space
- `help` - Show help

### Language Options

```bash
./setup.sh languages [option]
```

Options: `all`, `python`, `nodejs`, `r`, `java`, `rust`, `julia`, `go`

### Library Options

```bash
./setup.sh libraries [option]
```

Options: `all`, `x11`, `math`

---

## 🔧 Running Scripts Directly

All scripts can be run independently:

```bash
# Run any setup script directly
./setup/neovim.sh
./setup/languages.sh python
./system/clean-disk.sh
```

---

## ⚡ Pro Tips

1. **Check what will happen first:**
   ```bash
   ./setup.sh help
   ```

2. **Install incrementally:**
   ```bash
   ./setup.sh basic
   # Test, then add more
   ./setup.sh editor
   # Test, then add more
   ./setup.sh languages python
   ```

3. **Use specific components:**
   ```bash
   # Don't need everything? Just install what you need
   ./setup.sh basic languages
   ```

4. **Clean up regularly:**
   ```bash
   # Free up disk space
   ./setup.sh clean
   ```

5. **Scripts are idempotent:**
   ```bash
   # Safe to run multiple times
   ./setup.sh basic
   ./setup.sh basic  # Won't break anything
   ```

---

## 🚨 Important Notes

- Most commands require `sudo` password
- Language installers (Rust, Julia, Go) update your PATH
- After setup, **restart your shell** or run:
  ```bash
  source ~/.zshrc  # if using zsh
  source ~/.bashrc # if using bash
  ```

---

## 📚 Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check [MIGRATION.md](MIGRATION.md) if coming from old scripts
- Customize installed tools to your preferences

---

## 🆘 Troubleshooting

**Permission denied?**
```bash
chmod +x setup.sh
```

**Package not found?**
```bash
sudo apt update  # or your package manager
```

**Script should not run as root?**
```bash
# Don't use sudo with setup.sh
./setup.sh languages  # Correct
sudo ./setup.sh languages  # Wrong
```

**Need more help?**
```bash
./setup.sh help
cat README.md
```
