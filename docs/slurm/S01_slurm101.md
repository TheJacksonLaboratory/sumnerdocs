---
title: "Slurm Scheduler 101"
---

Slurm cheatsheet

*   [Slurm cheatsheet](https://slurm.schedmd.com/pdfs/summary.pdf)
*   [Tutorials](https://slurm.schedmd.com/tutorials.html)
*   Available options for [sbatch](https://slurm.schedmd.com/sbatch.html)
*   Available options for [srun](https://slurm.schedmd.com/srun.html)

## mksbatch

Bash wrapper to make slurm sbatch jobscript.

*   [Download mksbatch](https://github.com/TheJacksonLaboratory/sumnerdocs/blob/master/docs/confs/bin/mksbatch) script

!!! Warning "Require `dos2unix` command"
    `mksbatch` requires `dos2unix` command to make sure converted sbatch file is in unix-compliant text format. If you do not have it, you may try commenting it out before running the command.

*   Put in `~/bin/` with `chmod 755 ~/bin/mksbatch`
*   Make an example text file with **bash commands** you like to run, e.g.,

```sh
nano ~/mycmds.txt
```

with following contents:

```
echo "This will be run as sbatch job"
echo "List contents under /projects/"
ls /projects/

echo "print out user env"
env

sleep 10
echo "Good bye!"
```

*   To convert *mycmds.txt* into slurm sbatch compatible format

```sh
mksbatch -a ~/mycmds.txt
```

>This will make *~/mycmds*.sbatch* script with default job resources. To alter job resources, checkout help section for available options.

```sh
mksbatch --help
```

```
Wrapper to make slurm sbatch job format on HPC Sumner at JAX.

For options, read sbatch manpage at
https://slurm.schedmd.com/sbatch.html

Usage: mksbatch -a <path to files containing commands>

        -h  display this help and exit
        -a  REQUIRED: path to file containing commands to be run on cluster. This file will be copied verbatim following SBATCH arguments.
        -j  job name (default: j<random id>_username)
        -w  work directory (default: present work directory)
        -q  job queue (default: batch)
        -t  walltime in HH:MM:SS (default: 02:00:00)
        -m  memory in gb (default: 12G)
        -n  number of nodes (default: 1)
        -c  cpu cores per node (default: 2)
        -p  email notifications (default: FAIL)
        -s  if set to YES, export TMPDIR to /fastscratch/user/tmp (default: NO)
        -e  extra options to SBATCH (will be appended to default ones: "--requeue --export=all")
        -b  (Unused) node to exclude (default: none)
        -x  Submit job (default: NO; YES to submit)

Example: mksbatch -j "job1" -t 01:00:00 -m 12gb -c 1 -a ~/mycmds.txt

Quotes are important for variable names containig spaces and special characters.
```
