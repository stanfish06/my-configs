# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


# Put your fun stuff here.
# fzf
eval "$(fzf --bash)"

# Env
export NPM_CONFIG_PREFIX=$HOME/.local/
export PATH=$HOME/.local/bin:$PATH

# alias
alias l="ls -1 --color=auto --group-directories-first"
alias ll="ls -l --color=auto --group-directories-first"
