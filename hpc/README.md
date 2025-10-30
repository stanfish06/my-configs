# HPC Configuration Files

This directory contains configuration files for High-Performance Computing (HPC) environments.

## Files

### `.bashrc`
The main bash configuration file that sets up your HPC environment. This file is sourced automatically when you start a new bash session.

**Key Features:**
- Module system configuration
- Environment setup (Conda, Julia, R, Node.js)
- Custom functions for productivity
- Symbolic links to workspace directories
- Optimized for performance (desktop setup moved to separate script)

### `setup-desktop-entries.sh`
A standalone script for creating desktop shortcuts for scientific computing applications.

**Applications Configured:**
- MATLAB
- RStudio
- ilastik
- Jupyter Lab
- Fiji (ImageJ)

**Usage:**
```bash
# Run this script to create/update desktop entries
bash ~/path/to/hpc/setup-desktop-entries.sh
```

**Note:** This script is separate from `.bashrc` to avoid performance issues. Desktop entries only need to be created once or when updating application versions.

## Important Changes from Previous Version

1. **Modularization**: Desktop entry creation moved to separate script
2. **Bug Fixes**: Fixed logic errors in file existence checks
3. **Security**: Removed commented-out GitHub token
4. **Variable Usage**: Replaced hardcoded paths with `$HOME` and `$USER` variables
5. **Permissions**: Changed from 777 to 755 for better security
6. **Organization**: Added clear section headers and comments
7. **Performance**: Reduced startup time by moving one-time setup to separate script

## Customization

### Adding New Desktop Entries
Edit `setup-desktop-entries.sh` and add a new application following the existing pattern:

```bash
# Download icon
download_icon "appname" "https://url-to-icon.png"

# Create launcher script
create_launcher_script "appname" '#!/bin/bash
module load appname
appname'

# Create desktop entry
create_desktop_entry "appname" "false"  # or "true" for terminal apps
```

### Modifying Module Versions
Update the module load commands in either:
- `.bashrc` for modules loaded at startup
- `setup-desktop-entries.sh` for application-specific modules

## Troubleshooting

### Desktop entries not appearing
Run the setup script manually:
```bash
bash setup-desktop-entries.sh
```

### Module not found errors
Clear the lmod cache:
```bash
rm -f ~/.lmod.d/.cache/*
```

### Environment conflicts
Check that the correct conda environment is activated:
```bash
conda info --envs
```
