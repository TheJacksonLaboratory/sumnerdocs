#!/bin/bash

## user configs for Sumner Env
## https://github.com/TheJacksonLaboratory/linuxenv

#### API Tokens ####
GITHUB_PAT="blahblahblahblahblahblahblahblahblahblah"
# default GPG signing key
GPGKEY=blahblah

## max allowed jobs in active mode on HPC slurm
## this is not enforced unless you script your workflow to read this variable
## during job execution
RUNNING_JOBS=600

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

## tmux socket dir
TMUX_TMPDIR="${HOME}"/logs/tmux

## VERSION ##
SUM7VERSION="1.1"

## mypathmunge function is sourced from ~/.bash_profile
## if you like prepend some executable, use following format
## mypathmunge "${SPACK_ROOT}"/bin
## if you like append some executable, use following format
## mypathmunge "${SPACK_ROOT}"/bin after

## Make sure to export all variables and the uncomment next line ##
## export PATH LD_LIBRARY_PATH GITHUB_PAT

##################################### END ######################################
