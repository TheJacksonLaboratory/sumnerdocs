#!/bin/bash

## sumner configs which will override settings given under /etc/bashrc
## https://github.com/TheJacksonLaboratory/linuxenv

##### Unload HPC default modules #####
module unload gcc
module unload dot

## Add extra TERM options, if any
## Comment out if not applicable
case "$TERM" in
	'xterm') TERM=xterm-256color;;
	'screen') TERM=screen-256color;;
	'Eterm') TERM=Eterm-256color;;
	'xterm-kitty') TERM=xterm-kitty;;
esac

export TERM

## END ##
