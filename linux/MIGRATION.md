# Migration Guide

This guide helps you transition from the old monolithic scripts to the new modular structure.

## What Changed?

The linux setup scripts have been reorganized into a modular structure for better maintainability and ease of use.

### Old Structure
```
linux/
├── linux-setup.sh           # Monolithic setup script
├── install-languages.sh     # All languages in one script
├── install-libraries.sh     # All libraries in one script
├── install-i3status.sh      # i3status installer
├── install-raylib.sh        # Raylib installer
├── clean-disk.sh           # Disk cleanup
├── update-network.sh       # Network config
└── fzf-preview.sh          # FZF preview tool
```

### New Structure
```
linux/
├── setup.sh                # Main entry point with commands
├── README.md               # Comprehensive documentation
├── MIGRATION.md           # This file
├── lib/                   # Shared libraries
│   └── common.sh         # Common functions
├── setup/                 # Installation scripts
│   ├── basic-packages.sh
│   ├── neovim.sh
│   ├── wezterm.sh
│   ├── oh-my-zsh.sh
│   ├── languages.sh
│   ├── libraries.sh
│   ├── i3status.sh
│   └── raylib.sh
├── system/               # System maintenance
│   ├── clean-disk.sh
│   └── update-network.sh
└── tools/                # Utility scripts
    └── fzf-preview.sh
```

## Migration Map

Here's how to use the new scripts instead of the old ones:

| Old Command | New Command |
|-------------|-------------|
| `./linux-setup.sh` | `./setup.sh full` |
| `./install-languages.sh` | `./setup.sh languages` or `./setup/languages.sh` |
| `./install-libraries.sh` | `./setup.sh libraries` or `./setup/libraries.sh` |
| `./install-i3status.sh` | `./setup.sh i3status` or `./setup/i3status.sh` |
| `./install-raylib.sh` | `./setup.sh raylib` or `./setup/raylib.sh` |
| `./clean-disk.sh` | `./setup.sh clean` or `./system/clean-disk.sh` |
| `./update-network.sh` | `./system/update-network.sh` |
| `./fzf-preview.sh` | `./tools/fzf-preview.sh` |

## New Features

### 1. Modular Installation

You can now install components individually:

```bash
# Old: Had to edit script to comment out unwanted parts
./linux-setup.sh

# New: Install only what you need
./setup.sh basic           # Just basic packages
./setup.sh editor          # Just Neovim
./setup.sh terminal        # Just WezTerm
```

### 2. Granular Language Selection

```bash
# Old: Install all languages or edit the script
./install-languages.sh

# New: Install specific languages
./setup.sh languages python    # Just Python
./setup.sh languages rust      # Just Rust
./setup.sh languages           # All languages
```

### 3. Better Output and Error Handling

All scripts now have:
- Color-coded output (info, success, warning, error)
- Consistent error handling
- Better progress messages
- Package manager detection (apt, pacman, dnf)

### 4. Help System

```bash
# Get help for main script
./setup.sh help

# Get help for specific modules
./setup/languages.sh --help
./setup/libraries.sh --help
```

## What to Do with Old Scripts

### Option 1: Keep Both (Recommended Initially)

Keep both old and new scripts for a transition period. The old scripts still work.

### Option 2: Remove Old Scripts

Once you've verified the new scripts work for your needs, you can remove the old ones:

```bash
cd /home/runner/work/my-configs/my-configs/linux
rm linux-setup.sh
rm install-languages.sh
rm install-libraries.sh
rm install-i3status.sh
rm install-raylib.sh
rm clean-disk.sh
rm update-network.sh
rm fzf-preview.sh
```

Note: The new structure already includes copies in the appropriate directories.

## Breaking Changes

### Shebang Standardization

- Old scripts used mixed `#!/usr/bin/env zsh` and `#!/usr/bin/env bash`
- New scripts standardize on `#!/usr/bin/env bash` for better compatibility
- One old script had a typo: `#/usr/bin/env zsh` (missing `!`) - now fixed

### Script Behavior

- Scripts now exit on error (`set -e`)
- Better temporary file handling (files go to `/tmp`)
- Improved cleanup (no more `.tar.gz` files left in current directory)

### Configuration Files

The new `setup.sh full` command does NOT automatically copy config files. If you need this:

```bash
# From the old linux-setup.sh, you can still do this manually:
cp ../wezterm/linux/.wezterm.lua ~
ln -s "$(pwd)" ~/scripts
```

Or create a custom setup script in your own workflow.

## Testing Your Migration

1. Test with a non-destructive command first:
   ```bash
   ./setup.sh help
   ./setup.sh basic  # On a test machine
   ```

2. Run individual components you need:
   ```bash
   ./setup.sh languages python
   ./setup.sh editor
   ```

3. Verify everything works before removing old scripts

## Getting Help

- Read `README.md` for comprehensive documentation
- Run `./setup.sh help` for command reference
- Check individual scripts - they can be run directly
- All scripts are well-commented

## Questions?

If you encounter issues:
1. Check that scripts are executable: `chmod +x setup.sh`
2. Ensure you have sudo access
3. Check package manager is supported (apt, pacman, or dnf)
4. Review error messages - they now provide better context
