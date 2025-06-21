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
# create handy shortcuts for running common programs
if [ ! -d $user_home/Desktop/.scripts ]; then
	mkdir $user_home/Desktop/.scripts
fi
if [ ! -d $user_home/Desktop/.icons ]; then
	mkdir $user_home/Desktop/.icons
fi


# icons for softwares
matlab_icon_url="https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Matlab_Logo.png/1005px-Matlab_Logo.png"
ilastik_icon_url="https://chanzuckerberg.com/wp-content/uploads/2020/11/ilastik-fist-Anna-Kreshuk.png"
jupyter_icon_url="https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Jupyter_logo.svg/1200px-Jupyter_logo.svg.png"
fiji_icon_url="https://fiji.sc/site/logo.png"

if [ ! -f $user_home/Desktop/.icons/matlab.png ]; then
	wget -O $user_home/Desktop/.icons/matlab.png $matlab_icon_url 
fi
if [ ! -f $user_home/Desktop/.icons/ilastik.png ]; then
	wget -O $user_home/Desktop/.icons/ilastik.png $ilastik_icon_url
fi
if [ ! -f $user_home/Desktop/.icons/jupyter.png ]; then
	wget -O $user_home/Desktop/.icons/jupyter.png $jupyter_icon_url
fi
if [ ! -f $user_home/Desktop/.icons/fiji.png ]; then
	wget -O $user_home/Desktop/.icons/fiji.png $fiji_icon_url
fi

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

module load python/3.12
# source /nfs/turbo/umms-iheemske/python-venv/cellpose-gpu/bin/activate  # commented out by conda initialize
# always sync the environment to make sure the package versions are right
# this becomes unnecessary after turnning off pip install
# pip-sync /nfs/turbo/umms-iheemske/python-venv/cellpose-gpu/requirements_cellpose.txt

jupyter lab
EOF
chmod 777 $user_home/Desktop/.scripts/jupyter
if [ -f $user_home/Desktop/jupyter.desktop ]; then
	rm $user_home/Desktop/jupyter.desktop
fi
touch $user_home/Desktop/jupyter.desktop
cat > $user_home/Desktop/jupyter.desktop << EOF	
[Desktop Entry]
Type=Application
Name=jupyter
Exec=/home/$USER/Desktop/.scripts/jupyter
Icon=/home/$USER/Desktop/.icons/jupyter.png
Terminal=true
EOF
chmod 777 $user_home/Desktop/jupyter.desktop

if [ -f $user_home/Desktop/.scripts/fiji ]; then
	rm $user_home/Desktop/.scripts/fiji
fi
touch $user_home/Desktop/.scripts/fiji
cat > $user_home/Desktop/.scripts/fiji	<< 'EOF'
#!/bin/bash
module load fiji
fiji
EOF
chmod 777 $user_home/Desktop/.scripts/fiji
if [ -f $user_home/Desktop/fiji.desktop ]; then
	rm $user_home/Desktop/fiji.desktop
fi
touch $user_home/Desktop/fiji.desktop
cat > $user_home/Desktop/fiji.desktop << EOF	
[Desktop Entry]
Type=Application
Name=fiji
Exec=/home/$USER/Desktop/.scripts/fiji
Icon=/home/$USER/Desktop/.icons/fiji.png
Terminal=false
EOF
chmod 777 $user_home/Desktop/fiji.desktop

#clone github repo
git_token="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"
if [ ! -d $user_home/Desktop/HeemskerkLab_sync ]; then
	echo "Lab git repo does not exist. Create HeemskerkLab_sync on the desktop."
	git clone "https://HeemskerkLab:${git_token}@github.com/HeemskerkLab/HeemskerkLab.git" $user_home/Desktop/HeemskerkLab_sync
else
	echo "Lab git repo exists on the desktop. Try git pull latest changes."
	cd $user_home/Desktop/HeemskerkLab_sync
	git pull "https://HeemskerkLab:${git_token}@github.com/HeemskerkLab/HeemskerkLab.git" 2>/dev/null
	if [ $? -ne 0 ]; then
		echo "Fail to git pull latest changes. Check if git token expires or there are conflicts between remote and local."
		echo "Alternatively, you can delete the current Heemskerk_sync (or save a copy) to trigger a re-clone."
	fi
	cd $user_home
fi

#add symbolic link to the scratch folder
if [ ! -L $user_home/Desktop/${USER}_scratch_space ]; then
	ln -s /scratch/iheemske_root/iheemske0/$USER $user_home/Desktop/${USER}_scratch_space
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
export PATH=$PATH:/home/zyyu/neovim/nvim-linux-x86_64/bin
#----------For rust----------
export PATH=$PATH:/home/zyyu/.cargo/bin

#----------Custom commands----------
function today() {
	date +%Y-%m-%d
}
function imgcat() {
	~/WezTerm-20221119-145034-49b9839f-Ubuntu18.04.AppImage imgcat "$1"
}
function fzf-img() {
	local width="${1:-auto}"
	fzf --preview "case {} in 
		*.png|*.jpg|*.tif) ~/WezTerm-20221119-145034-49b9839f-Ubuntu18.04.AppImage imgcat --width $width {} ;;
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
    *:/home/zyyu/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/zyyu/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<

#----------nvidia----------
# make sure to activate corresponding env first
# doing so because it is more convenient to install c/c++ libraries with conda
conda config --set auto_activate_base False
conda activate hpc
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
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
export PYTHON_JULIAPKG_EXE="/home/zyyu/.julia/juliaup/julia-1.12.0-beta1+0.x64.linux.gnu/bin/julia"

# vi mode
set -o vi
export EDITOR="vim"
