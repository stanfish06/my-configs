#!/bin/bash
# Desktop Entry Setup Script for HPC Environment
# This script sets up desktop shortcuts for common scientific computing applications
# Run this script manually after login or when you want to update desktop entries

user_home="${HOME}"

# Function to create desktop directories
setup_directories() {
    mkdir -p "$user_home/Desktop/.scripts"
    mkdir -p "$user_home/Desktop/.icons"
}

# Function to download an icon if it doesn't exist
download_icon() {
    local name="$1"
    local url="$2"
    local icon_path="$user_home/Desktop/.icons/${name}.png"
    
    if [ ! -f "$icon_path" ]; then
        echo "Downloading ${name} icon..."
        wget -q -O "$icon_path" "$url" 2>/dev/null || echo "Failed to download ${name} icon"
    fi
}

# Function to create a launcher script
create_launcher_script() {
    local name="$1"
    local content="$2"
    local script_path="$user_home/Desktop/.scripts/${name}"
    
    # Overwrite the script with new content
    echo "$content" > "$script_path"
    chmod 755 "$script_path"
}

# Function to create a desktop entry
create_desktop_entry() {
    local name="$1"
    local terminal="${2:-false}"
    local desktop_path="$user_home/Desktop/${name}.desktop"
    
    # Overwrite the desktop entry with new content
    cat > "$desktop_path" << EOF
[Desktop Entry]
Type=Application
Name=${name}
Exec=${user_home}/Desktop/.scripts/${name}
Icon=${user_home}/Desktop/.icons/${name}.png
Terminal=${terminal}
EOF
    chmod 755 "$desktop_path"
}

# Setup directories
setup_directories

# Download icons
download_icon "matlab" "https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Matlab_Logo.png/1005px-Matlab_Logo.png"
download_icon "ilastik" "https://chanzuckerberg.com/wp-content/uploads/2020/11/ilastik-fist-Anna-Kreshuk.png"
download_icon "jupyter" "https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Jupyter_logo.svg/1200px-Jupyter_logo.svg.png"
download_icon "fiji" "https://fiji.sc/site/logo.png"
download_icon "rstudio" "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/RStudio_logo_flat.svg/1200px-RStudio_logo_flat.svg.png"

# Setup MATLAB
create_launcher_script "matlab" '#!/bin/bash
module load matlab/R2024b
matlab -desktop'
create_desktop_entry "matlab" "false"

# Setup RStudio
create_launcher_script "rstudio" '#!/bin/bash
module load use.own
module load Rstudio 
conda activate hpc
export R_HOME=$HOME/.conda/envs/hpc/lib/R
export RSTUDIO_WHICH_R=$HOME/.conda/envs/hpc/bin/R
export R_LIBS_USER=$HOME/.conda/envs/hpc/lib/R/library
export PATH=$HOME/.conda/envs/hpc/bin:$PATH
export LD_LIBRARY_PATH="$HOME/.conda/envs/hpc/lib/R/lib:$HOME/.conda/envs/hpc/lib:${LD_LIBRARY_PATH}" 
exec rstudio'
create_desktop_entry "rstudio" "false"

# Setup ilastik
create_launcher_script "ilastik" '#!/bin/bash
module load Bioinformatics ilastik/1.4.0
run_ilastik.sh'
create_desktop_entry "ilastik" "false"

# Setup Jupyter
create_launcher_script "jupyter" '#!/bin/bash
module purge
module load python/3.12
source /nfs/turbo/umms-iheemske/python-venv/cellpose-gpu/bin/activate
# Environment sync is unnecessary after turning off pip install
# pip-sync /nfs/turbo/umms-iheemske/python-venv/cellpose-gpu/requirements_cellpose.txt

jupyter lab'
create_desktop_entry "jupyter" "true"

# Setup Fiji
create_launcher_script "fiji" '#!/bin/bash
module load fiji
fiji'
create_desktop_entry "fiji" "false"

echo "Desktop entries setup complete!"
