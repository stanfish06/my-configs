# .bashrc - HPC Environment Configuration

#==============================================================================
# SYSTEM INITIALIZATION
#==============================================================================

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User-specific PATH configuration
if ! [[ "$PATH" =~ $HOME/.local/bin:$HOME/bin: ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

#==============================================================================
# MODULE SYSTEM SETUP
#==============================================================================

# Unload all modules first
module purge

# Setup custom modules
if [ ! -d "$HOME/Lmod" ]; then
    my_modules_setup
fi

# Clear lmod cache to ensure module list is updated
if [ -d "$HOME/.lmod.d/.cache" ]; then
    rm -f "$HOME/.lmod.d/.cache"/*
fi

# Copy config files to the home lmod folder
rm -rf "$HOME/Lmod"/*
cp -rn /nfs/turbo/umms-iheemske/modules-share/lmod-config/* "$HOME/Lmod/"
# module load use.own (this enables custom modules but slow things down a lot)

#==============================================================================
# DESKTOP SHORTCUTS SETUP
#==============================================================================

# Desktop shortcuts are now managed by a separate script.
# To setup or update desktop entries, run:
#   bash ~/hpc/setup-desktop-entries.sh
# This prevents performance issues on every shell startup.

# matlab
if [ ! -f $user_home/Desktop/.scripts/matlab ]; then
	rm $user_home/Desktop/.scripts/matlab
fi
touch $user_home/Desktop/.scripts/matlab
# you can modify this part for a different version of matlab, etc.
cat > $user_home/Desktop/.scripts/matlab << 'EOF'	
#!/bin/bash

module load matlab/R2024b
matlab -desktop
EOF
chmod 777 $user_home/Desktop/.scripts/matlab
if [ -f $user_home/Desktop/matlab.desktop ]; then
	rm $user_home/Desktop/matlab.desktop
fi
touch $user_home/Desktop/matlab.desktop
cat > $user_home/Desktop/matlab.desktop << EOF	
[Desktop Entry]
Type=Application
Name=matlab
Exec=/home/$USER/Desktop/.scripts/matlab
Icon=/home/$USER/Desktop/.icons/matlab.png
Terminal=false
EOF
chmod 777 $user_home/Desktop/matlab.desktop

# rstudio
if [ ! -f $user_home/Desktop/.scripts/rstudio ]; then
	rm $user_home/Desktop/.scripts/rstudio
fi
touch $user_home/Desktop/.scripts/rstudio
cat > $user_home/Desktop/.scripts/rstudio << 'EOF'	
#!/bin/bash
module load use.own
module load Rstudio 
conda activate hpc
export R_HOME=/home/zyyu/.conda/envs/hpc/lib/R
export RSTUDIO_WHICH_R=/home/zyyu/.conda/envs/hpc/bin/R
export R_LIBS_USER=/home/zyyu/.conda/envs/hpc/lib/R/library
export PATH=/home/zyyu/.conda/envs/hpc/bin:$PATH
export LD_LIBRARY_PATH="/home/zyyu/.conda/envs/hpc/lib/R/lib:/home/zyyu/.conda/envs/hpc/lib:${LD_LIBRARY_PATH}" 
exec rstudio
EOF
chmod 777 $user_home/Desktop/.scripts/rstudio
if [ -f $user_home/Desktop/rstudio.desktop ]; then
	rm $user_home/Desktop/rstudio.desktop
fi
touch $user_home/Desktop/rstudio.desktop
cat > $user_home/Desktop/rstudio.desktop << EOF	
[Desktop Entry]
Type=Application
Name=rstudio
Exec=/home/$USER/Desktop/.scripts/rstudio
Icon=/home/$USER/Desktop/.icons/rstudio.png
Terminal=false
EOF
chmod 777 $user_home/Desktop/rstudio.desktop

# ilastik
if [ -f $user_home/Desktop/.scripts/ilastik ]; then
	rm $user_home/Desktop/.scripts/ilastik
fi
touch $user_home/Desktop/.scripts/ilastik
# there is only one version of ilastik on the greatlakes server.
# one can download a binary and add to path if a different version is preferred
cat > $user_home/Desktop/.scripts/ilastik << 'EOF'	
#!/bin/bash

module load Bioinformatics ilastik/1.4.0
run_ilastik.sh
EOF
chmod 777 $user_home/Desktop/.scripts/ilastik
if [ -f $user_home/Desktop/ilastik.desktop ]; then
	rm $user_home/Desktop/ilastik.desktop
fi
touch $user_home/Desktop/ilastik.desktop
cat > $user_home/Desktop/ilastik.desktop << EOF	
[Desktop Entry]
Type=Application
Name=ilastik
Exec=/home/$USER/Desktop/.scripts/ilastik
Icon=/home/$USER/Desktop/.icons/ilastik.png
Terminal=false
EOF
chmod 777 $user_home/Desktop/ilastik.desktop

# jupyter
# note that this environment contains cellpose and jupyter lab  for segmentation and visualization
# one can also create their own envrionment with pip venv or conda (just need to load anaconda)
if [ -f $user_home/Desktop/.scripts/jupyter ]; then
	rm $user_home/Desktop/.scripts/jupyter
fi
touch $user_home/Desktop/.scripts/jupyter
cat > $user_home/Desktop/.scripts/jupyter	<< 'EOF'
#!/bin/bash
# this kills all currently running jupyter servers
# maybe it is a bad idea, maybe people need multiple notebooks
# ps aux | grep jupyter | grep -v grep | grep -v "$0" | awk '{print $2}' | xargs -r kill

# NOTE: The paths below are specific to the University of Michigan HPC environment
# Adjust these paths according to your HPC cluster configuration

# Create symbolic link to scratch folder
if [ ! -L "$HOME/Desktop/${USER}_scratch_space" ]; then
    ln -s /scratch/iheemske_root/iheemske0/"$USER" "$HOME/Desktop/${USER}_scratch_space"
fi

# Create symbolic link to turbo space
if [ ! -L "$HOME/Desktop/lab_turbo_space" ]; then
    ln -s /nfs/turbo/umms-iheemske/ "$HOME/Desktop/lab_turbo_space"
fi

#==============================================================================
# PATH CONFIGURATION
#==============================================================================

# Neovim
if [ -d "$HOME/neovim/nvim-linux-x86_64/bin" ]; then
    export PATH="$PATH:$HOME/neovim/nvim-linux-x86_64/bin"
fi

# Rust
if [ -d "$HOME/.cargo/bin" ]; then
    export PATH="$PATH:$HOME/.cargo/bin"
fi

#==============================================================================
# CUSTOM FUNCTIONS
#==============================================================================

# Get today's date in YYYY-MM-DD format
function today() {
    date +%Y-%m-%d
}

# Display image in terminal (WezTerm)
function imgcat() {
    ~/WezTerm-20221119-145034-49b9839f-Ubuntu18.04.AppImage imgcat "$1"
}

# FZF image preview (WezTerm)
function fzf-img() {
    local width="${1:-auto}"
    fzf --preview "case {} in 
        *.png|*.jpg|*.tif) ~/WezTerm-20221119-145034-49b9839f-Ubuntu18.04.AppImage imgcat --width $width {} ;;
        *) echo not image ;;
    esac" --preview-window='down'
}

# FZF image preview (Kitty)
function fzf-kitty-img() {
    local width="${1:-auto}"
    local height="${2:-auto}"
    fzf --preview "case {} in 
        *.png|*.jpg|*.tif) kitten icat --clear --transfer-mode=stream --stdin=no --place ${width}x${height}@0x0 {} ;;
        *) echo not image ;;
    esac" --preview-window='down'
}

#==============================================================================
# CONDA INITIALIZATION
#==============================================================================

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if __conda_setup="$('/sw/pkgs/arc/python3.11-anaconda/2024.02-1/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"; then
    eval "$__conda_setup"
else
    if [ -f "/sw/pkgs/arc/python3.11-anaconda/2024.02-1/etc/profile.d/conda.sh" ]; then
        . "/sw/pkgs/arc/python3.11-anaconda/2024.02-1/etc/profile.d/conda.sh"
    else
        export PATH="/sw/pkgs/arc/python3.11-anaconda/2024.02-1/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

#==============================================================================
# JULIAUP INITIALIZATION
#==============================================================================

# >>> juliaup initialize >>>
# !! Contents within this block are managed by juliaup !!
case ":$PATH:" in
    *:$HOME/.juliaup/bin:*)
        ;;
    *)
        export PATH="$HOME/.juliaup/bin${PATH:+:${PATH}}"
        ;;
esac
# <<< juliaup initialize <<<

#==============================================================================
# ENVIRONMENT-SPECIFIC CONFIGURATION
#==============================================================================

# Conda environment setup
conda config --set auto_activate_base False
conda activate hpc

# Library paths
# Make sure to delete dbus installed through conda and use dbus from /usr/lib64
# Otherwise desktop can't launch
export LD_LIBRARY_PATH=/sw/pkgs/arc/gcc/13.2.0/lib64:/sw/pkgs/arc/rust/1.81.0/lib:/usr/lib64
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

# R configuration (conda environment)
export R_HOME="$HOME/.conda/envs/hpc/lib/R"
export RSTUDIO_WHICH_R="$HOME/.conda/envs/hpc/bin/R"
export PATH="$PATH:$HOME/.conda/envs/hpc/bin"
export R_LIBS_SITE="$HOME/.conda/envs/hpc/lib/R/library"

# SuiteSparse configuration
export SUITESPARSE_INCLUDE_DIR=$CONDA_PREFIX/include/suitesparse
export SUITESPARSE_LIBRARY_DIR=$CONDA_PREFIX/lib

#==============================================================================
# NODE.JS / NVM
#==============================================================================

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

#==============================================================================
# JULIA CONFIGURATION
#==============================================================================

# Note that this will be the julia used by juliapkg
# 1.12 solves a Download.jl issue that prevents julia project creation on hpc
juliaup default 1.12.0-beta1
export PYTHON_JULIAPKG_EXE="$HOME/.julia/juliaup/julia-1.12.0-beta1+0.x64.linux.gnu/bin/julia"

#==============================================================================
# R SYSTEM CONFIGURATION
#==============================================================================

# Using the same R conda-wise and system-wise so that Rcpp doesn't cause issues
conda deactivate
# module load R/4.5.1

# Hugging Face cache
export HF_HOME=/scratch/iheemske_root/iheemske0/$USER/huggingface_cache

# Singularity cache
export SINGULARITY_CACHEDIR=/scratch/iheemske_root/iheemske0/$USER/singularity_cache

#==============================================================================
# EDITOR CONFIGURATION
#==============================================================================

# Vi mode (note: may crash tmux session, check back later to fix)
set -o vi
export EDITOR="vim"

#==============================================================================
# SDKMAN (MUST BE AT THE END)
#==============================================================================

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
