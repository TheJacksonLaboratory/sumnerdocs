#!/bin/bash

## user cronjob configs for Sumner Env
## https://github.com/TheJacksonLaboratory/linuxenv
export PS1="[\u@\h \W]\\$ "

# SET user env ##
PATH="/home/foo/bin:/projects/verhaak-lab/foo/sumnerenv_os7/bin:/home/foo/anaconda3/bin:/home/foo/anaconda3/condabin:/home/foo/.local/bin:/projects/verhaak-lab/foo/sumnerenv_os7/opt/bin:/projects/verhaak-lab/foo/sumnerenv_os7/local/bin:/projects/verhaak-lab/helixenv_os6/opt/apps/go/go1.12.7/bin:/cm/shared/apps/slurm/18.08.8/sbin:/cm/shared/apps/slurm/18.08.8/bin:/cm/local/apps/singularity/current/bin:/home/foo/.autojump/bin:/projects/verhaak-lab/helixenv_os6/opt/apps/spack/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"

LD_LIBRARY_PATH="/home/foo/anaconda3/lib:/home/foo/anaconda3/lib/R/lib:/home/foo/anaconda3/jre/lib:/home/foo/anaconda3/jre/lib/amd64/server:/cm/shared/apps/slurm/18.08.8/lib64/slurm:/cm/shared/apps/slurm/18.08.8/lib64:/usr/lib64:/usr/lib"

#### API Tokens ####
GITHUB_PAT="blahblahblahblahblahblahblahblahblahblah"
# default GPG signing key
GPGKEY=blahblah

## screen socket directory
## do chmod 700 "${HOME}"/.screen
SCREENDIR="${HOME}"/.screen

## GLOBUS JAX endpoint
## Identical for jax-wide users, ask RIT for this
GLOBUSEP=blahblahblahblahblahblahblahblahblahblah

## OS7 HOME ##
SUM7ENV="/projects/foo/sumnerenv_os7"
SUM7BIN="${SUM7ENV}/bin"
SUM7OPTBIN="${SUM7ENV}/opt/bin"
SUM7APPS="${SUM7ENV}/opt/apps"
SUM7MODULES="${SUM7ENV}/modules"

#### setup custom module path ####
module use --append "${SUM7MODULES}"

## Set TZ
TZ='America/New_York'

## micro terminal
MICRO_COLORTERMINAL=1

## color terminal ##
## This must be set before reading global initialization such as /etc/bashrc.
SEND_256_COLORS_TO_REMOTE=1
## edit TERM options in override/S01_override.sh AFTER /etc/bashrc is loaded.

## PS1 for loading bash env ##
PS1="[\u@\h:\w]"

## tmux socket dir
TMUX_TMPDIR="${HOME}"/logs/tmux

## VERSION ##
SUM7VERSION="1.1"

## Make sure to export all variables and the uncomment next line ##
## export PATH LD_LIBRARY_PATH GITHUB_PAT

## END ##
