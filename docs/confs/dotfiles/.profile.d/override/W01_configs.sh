#!/bin/bash

## Load config only if on Winter HPC
## @sbamin

## switch to winter-specific conda env and modules
if [[ "$(hostname)" == *"winter"* ]]; then
	#### Activate CONDA in subshell ####
	## Read https://github.com/conda/conda/issues/7980 and
	## https://stackoverflow.com/a/56162704/1243763
	## CONDA_BASE=$(conda info --base)
	. "${CONDA_BASE}"/etc/profile.d/conda.sh

	## Replace tf-gpu with your conda env id and then uncomment
	## CONDA_CHANGEPS1=false conda activate tf-gpu
	#### END CONDA SETUP ####

	## module load my_winter_module
fi

## END ##
