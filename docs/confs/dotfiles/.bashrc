#!/bin/bash

## default .bashrc for Helix Env
## https://github.com/TheJacksonLaboratory/linuxenv

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

############ global bashrc #############
# Source global definitions only if not loaded before
SYSBASH=$(echo "$PATH" | grep -Ec "local|slurm")

if [ -f /etc/bashrc ] && [ "${SYSBASH}" = 0 ]; then
	# echo "Loading /etc/bashrc"
	. /etc/bashrc
fi

############# bash aliases #############
if [ -f ~/.bash_aliases ]; then
        . "${HOME}"/.bash_aliases
fi

############# bash history #############
## following will backup your bash command history in ~/.history/ directory.
## you can query it using command deephs, e.g., "deephs samtools" from terminal
HISTFILE="${HOME}"/.history/"$(date +%Y-%W)".hist

if [[ ! -e "$HISTFILE" ]]; then
    mkdir -p ~/.history
    touch "$HISTFILE"
    LASTHIST=~/.history/"$(ls -tr ${HOME}/.history/ | tail -1)"
    if [[ -e "$LASTHIST" ]]; then
        tail -5000 "$LASTHIST" > "$HISTFILE"
        # Write a divider to identify where the prior day's session history ends
        echo "##########################################################" >> "$HISTFILE"
    fi
fi

HISTSIZE=100000
HISTFILESIZE=1000000
## Not required as history is sorted per week.
## HISTTIMEFORMAT="%d/%m/%y %T "

############ colour prompt #############
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

############# bash options #############
## please read more on internet about all of these options
set -o noclobber # prevent overwriting files with cat
set -o ignoreeof # stops ctrl+d from logging me out

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend
shopt -s histverify
shopt -s checkwinsize
## dir expand
shopt -s direxpand

export SYSBASH HISTFILE HISTSIZE HISTFILESIZE HISTCONTROL

####### CONDA SETUP ######

## If conda env is set by a user, conda config will add init code here.
## Do not add/edit any line of manual code after this line.

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/foo/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/foo/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/foo/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/foo/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
##################################### END ######################################
