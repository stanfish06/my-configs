# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
# unload all modules first
module purge
user_home=/home/$USER

# Desktop shortcuts (MATLAB, RStudio, Jupyter, ilastik, Fiji) are created on demand.
# Run hpc/setup-desktop-entries.sh once to set them up.

#add symbolic link to the scratch folder
if [ ! -L $user_home/Desktop/${USER}_scratch_space ]; then
	ln -s /scratch/iheemske_root/iheemske0/$USER $user_home/Desktop/${USER}_scratch_space
fi
#turbo
if [ ! -L $user_home/Desktop/lab_turbo_space ]; then
	ln -s /nfs/turbo/umms-iheemske/ $user_home/Desktop/lab_turbo_space
fi

#add modules
if [ ! -d $user_home/Lmod ]; then
	my_modules_setup
fi
#clear lmod cache otherwise module list won't be updated
if [ -d $user_home/.lmod.d/.cache ]; then
	rm -f $user_home/.lmod.d/.cache/*
fi
#copy config files to the home lmod folder
rm -rf $user_home/Lmod/*
cp -rn /nfs/turbo/umms-iheemske/modules-share/lmod-config/* $user_home/Lmod/
# module load use.own (this enables custom modules but slow things down a lot)

#----------For neovim----------
export PATH=$PATH:$HOME/neovim/nvim-linux-x86_64/bin
#----------For rust----------
export PATH=$PATH:$HOME/.cargo/bin
#----------For go----------
export PATH=$PATH:$HOME/go/bin

#----------Custom commands----------
function today() {
	date +%Y-%m-%d
}
function imgcat() {
	~/WezTerm-20221119-145034-49b9839f-Ubuntu18.04.AppImage imgcat "$1"
}
alias icat="kitten icat"
function fzf-img() {
	local width="${1:-auto}"
	fzf --preview "case {} in 
		*.png|*.jpg|*.tif) ~/WezTerm-20221119-145034-49b9839f-Ubuntu18.04.AppImage imgcat --width $width {} ;;
		*) echo not image ;;
	esac" --preview-window='down'
}
function fzf-kitty-img() {
	local width="${1:-auto}"
	local height="${2:-auto}"
	fzf --preview "case {} in 
		*.png|*.jpg|*.tif) kitten icat --clear --transfer-mode=stream --stdin=no --place ${width}x${height}@0x0 {} ;;
		*) echo not image ;;
	esac" --preview-window='down'
}

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/sw/pkgs/arc/python3.11-anaconda/2024.02-1/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
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

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:$HOME/.juliaup/bin:*)
        ;;

    *)
        export PATH=$HOME/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<

#----------nvidia----------
# make sure to activate corresponding env first
# doing so because it is more convenient to install c/c++ libraries with conda
conda config --set auto_activate_base False
conda activate hpc
#make sure to delete dbus installed through conda and use dbus from /usr/lib64. Otherwise desktop cant launch
export LD_LIBRARY_PATH=/sw/pkgs/arc/gcc/13.2.0/lib64:/sw/pkgs/arc/rust/1.81.0/lib:/usr/lib64
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
export R_HOME=$HOME/.conda/envs/hpc/lib/R
export RSTUDIO_WHICH_R=$HOME/.conda/envs/hpc/bin/R
export PATH=$PATH:$HOME/.conda/envs/hpc/bin
export R_LIBS_SITE=$HOME/.conda/envs/hpc/lib/R/library
#----------sksparse----------
export SUITESPARSE_INCLUDE_DIR=$CONDA_PREFIX/include/suitesparse
export SUITESPARSE_LIBRARY_DIR=$CONDA_PREFIX/lib

#----------nodejs----------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#----------julia----------
# note that this will be the julia used by juliapkg
# 1.12 solves a Donwload.jl issue that prevents julia project creation on hpc
juliaup default 1.12.0-beta1
export PYTHON_JULIAPKG_EXE="$HOME/.julia/juliaup/julia-1.12.0-beta1+0.x64.linux.gnu/bin/julia"

#----------R----------
# R is stupid
# the current method seems to be using the same R conda-wise and system-wise so that rcpp dont fuck up
conda deactivate
# module load R/4.5.1

#----------huggingface----------
export HF_HOME=/scratch/iheemske_root/iheemske0/$USER/huggingface_cache

# vi mode crashes tmux session, check back later to see if you can fix that
# vi mode
set -o vi
export EDITOR="vim"

# SINGULARITY cache
export SINGULARITY_CACHEDIR=/scratch/iheemske_root/iheemske0/$USER/singularity_cache
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
