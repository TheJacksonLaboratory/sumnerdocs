#!/bin/bash

## default .bash_profile for Sumner Env
## https://github.com/TheJacksonLaboratory/linuxenv

## Order of setting up bash in login shell
## https://apple.stackexchange.com/a/13019/68197
## /etc/profile, /etc/profile.d/*.sh, ~/.bash_profile
## then depending upon ~/.bash_profile order (as in here),
## ~/.profile.d/*.sh, ~/.bashrc, and /etc/bashrc which is again conditional
## on ~/.bashrc settings.

############## Debug Mode ##############
# set -x
# echo "Start sourcing .bash_profile"
# sleep 2
############ End Debug Mode ############

################################# user configs #################################
## function to load user configs from ~/.profile.d/
mypathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}

## load user configs
if [ -d "${HOME}"/.profile.d ]; then
  for i in "${HOME}"/.profile.d/*.sh; do
    if [ -r "$i" ]; then
      	if [ "${-#*i}" != "$-" ]; then
            . "$i" >/dev/null 2>&1
        else
            . "$i" >/dev/null 2>&1
        fi
    fi
  done
  unset i
fi

############################### end user configs ###############################

################################### END ZONE ###################################
## Avoid adding more configs below this line, instead add user configs in
## ~/.profile.d/Snn_*.sh files to load configs in sequence.

####### user and system .bashrc ########
# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

####### OVERRIDE SYSTEM CONFIGS ########
## load user configs that can override /etc/bashrc settings
if [ -d "${HOME}"/.profile.d/override ]; then
  for i in "${HOME}"/.profile.d/override/*.sh; do
    if [ -r "$i" ]; then
      	if [ "${-#*i}" != "$-" ]; then
            . "$i" >/dev/null 2>&1
        else
            . "$i" >/dev/null 2>&1
        fi
    fi
  done
  unset i
fi

unset -f mypathmunge

################################### SET PATH ###################################
## User specific environment and startup programs
## Rewriting PATH ##
## We want user and anaconda paths to precede system paths, esp. this string:
## /usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin which contains
## most of system default libs,
## i.e., incompatible versions of gcc, g++, and other devtools.
## Make sure to append PATH variable in case sysadmin adds more tools in 
## /etc/bashrc. This will duplicate most of path but it doesn't matter as we
## set precedence for user configs in PATH string and include all of PATH
## locations.
## Also note ${PATH:+:$PATH} before system paths. This will force system paths to
## append at the end but module paths to precede system paths.

export deprecPATH=$PATH

## Set PATH based on HPC ##
if [[ "$(hostname)" == *"sumner"* ]]; then
	PATH="${HOME}/bin:${SUM7ENV}/bin:${HOME}/anaconda3/bin:${HOME}/anaconda3/condabin:${HOME}/.local/bin:${SUM7ENV}/opt/bin:${SUM7ENV}/local/bin:/cm/shared/apps/slurm/current/sbin:/cm/shared/apps/slurm/current/bin${PATH:+:$PATH}:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
	MYENV="SUMNER7"
elif [[ "$(hostname)" == *"winter"* ]]; then
	PATH="${HOME}/bin:${SUM7ENV}/bin:${HOME}/anaconda3/envs/tf-gpu/bin:${HOME}/anaconda3/condabin:${HOME}/.local/bin:${HOME}/anaconda3/bin:${SUM7ENV}/opt/bin:${SUM7ENV}/local/bin:/cm/shared/apps/slurm/current/sbin:/cm/shared/apps/slurm/current/bin:${SUM7ENV}/opt/gpu/tensorRT/TensorRT-6.0.1.5/bin${PATH:+:$PATH}:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
	MYENV="WINTER7"
else
	PATH="${HOME}/bin:${SUM7ENV}/bin:${HOME}/anaconda3/bin:${HOME}/anaconda3/condabin:${HOME}/.local/bin:${SUM7ENV}/opt/bin:${SUM7ENV}/local/bin:/cm/shared/apps/slurm/current/sbin:/cm/shared/apps/slurm/current/bin${PATH:+:$PATH}:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
	MYENV="UNKNOWN"
fi

#### remove duplicate PATH entries BUT preserve order of entries ###
## prefer bash solution
## bash: https://unix.stackexchange.com/a/40973/28675
## perl: https://unix.stackexchange.com/a/50169/28675

if [ -n "$PATH" ]; then
	## THIS UNSETS PATH - CAREFUL ON CHOICE OF COMMANDS YOU HAVE NOW!
	  old_PATH=$PATH:; PATH=
	  while [ -n "$old_PATH" ]; do
	    x=${old_PATH%%:*}       # the first remaining entry
	    case $PATH: in
	      *:"$x":*) ;;          # already there
	      *) PATH=$PATH:$x;;    # not there yet
	    esac
	    old_PATH=${old_PATH#*:}
	  done
	  PATH=${PATH#:}
	  unset old_PATH x
fi

export PATH MYENV

## Reset PS1 and never keep it unset else sub-shells may not be properly
## configured for conda env.
## base conda env will not get any prefix to PS1 but conda activate will prepend
## env name to PS1.
# PS1="[\u@\h:\w]"
# export PS1

bldred='\e[1;31m' # Red
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
txtrst='\e[0m'    # Text Reset - Useful for avoiding color bleed

PROMPT_COMMAND="printf '\n'"
PS1="\[$bldred\]\u\[$txtrst\]@\[$bldwht\]\h\[$txtrst\]:\[$bldcyn\]\w\[$txtrst\]$ "
export PS1

##################################### END ######################################
