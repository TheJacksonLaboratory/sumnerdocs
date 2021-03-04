#!/bin/bash

## sumner modules and system compiled libs
## https://github.com/TheJacksonLaboratory/linuxenv

## This file will setup custom loading of tools which are not part of
## conda environment

## comment following line if you like to source this file.
## Make sure to put valid paths for tool-specific configurations you find in
## tool documentation.
exit 0

## may not work all the time with conda env
## avoid loading modules using module load
## instead look for what module is loading using module show and write those
## commands here instead.

#### Unloading modules ####
## Use override/S01_override.sh to unload system-installed modules

### singularity ###
## Not availble on login nodes
## Since this script will load sequentially after S01.., it will inherit all variables
## e.g., SUM7ENV from S01 script unless you forgot to export that variable in S01 script
MANPATH="${SUM7ENV}/local/share/man:/cm/local/apps/singularity/current/share/man${MANPATH:+:$MANPATH}"
## cache, read https://sylabs.io/guides/3.0/user-guide/build_env.html
SINGULARITY_CACHEDIR="/projects/foo/containers/cache/singularity"
## path were built SIF images are stored
SINGULARITY_SIF="/projects/foo/containers/sifbin"

## julia ##
JULIA_DEPOT_PATH="/projects/foo/sumnerenv_os7/pkgs/julia/v1.4:/projects/foo/sumnerenv_os7/opt/apps/julia/julia-1.4.0/local/share/julia:/projects/foo/sumnerenv_os7/opt/apps/julia/julia-1.4.0/share/julia"

## rust-lang ##
CARGO_HOME=/projects/foo/sumnerenv_os7/opt/apps/rust/default/cargo
RUSTUP_HOME=/projects/foo/sumnerenv_os7/opt/apps/rust/default/rust

## nim lang ##
NIMBLE_DIR=/projects/foo/sumnerenv_os7/opt/apps/nim/default/nimble

## GOPATH ##
GOROOT=/projects/foo/sumnerenv_os7/opt/apps/go/go_1.14.2
GOPATH=/projects/foo/sumnerenv_os7/opt/apps/go/gopkgs/v1.14.2

## Make sure to export all variables ##
export MANPATH SINGULARITY_CACHEDIR SINGULARITY_SIF JULIA_DEPOT_PATH CARGO_HOME RUSTUP_HOME NIMBLE_DIR GOROOT GOPATH

## Update PATH ##
## mypathmunge function is sourced from ~/.bash_profile
mypathmunge "/cm/local/apps/singularity/current/bin:${GOROOT}/bin:${GOPATH}/bin:${SUM7APPS}/julia/julia-1.4.0/bin:${CARGO_HOME}/bin:${NIMBLE_DIR}/bin:${HOME}/.aspera/cli/bin:${HOME}/.aspera/connect/bin"

## END ##
