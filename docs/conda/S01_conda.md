---
title: "Set up conda environment"
---

!!! danger ":skull_and_crossbones: :construction: Work In Progress :construction: :skull_and_crossbones:"
    Documentation is in alpha stage and not intended for setting up Sumner HPC environment.

## First-time Login

```sh
ssh login.sumner.jax.org

## Know OS and kernel version
cat /etc/redhat-release
uname -a
```

>Running CentOS Linux release 7.7.1908 (Core)  
>Linux sumner-log2 3.10.0-1062.1.2.el7.x86_64 #1 SMP Mon Sep 30 14:19:46 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux  

*   First, login to sumner with a clean env, i.e., as it ships with default profile from HPC team, and nothing added in following files. Default bash configuration for sumner looks similar to [/confs/dotfiles/hpc_default_env/](/confs/dotfiles/hpc_default_env/).

```sh
~/.bashrc
~/.bash_profile
~/.bash_aliases # if it exists
~/.profile # if it exists
```

*   If you had custom bash configs (linuxbrew, previous conda, etc.), comment those out from above files. If you'd linuxbrew installed, make sure to disable it unless you are confident that conda and linuxbrew can work in harmony!

>Same goes for `~/.local/` directory which should not exist at the fresh startup. If it does, you may have installed some tools using python, perl, or other non-root based setup scripts. For clean setup, `~/.local` directory needs to be removed from user environment, i.e., either rename it to say, ~/.local_deprecated or archive it somewhere!

*   Make sure to logout and login to sumner again for a clean env to take an effect. Once you login, your `env` should look something similar to this one. Note that PATH variable will default to cent os 7 standard paths and LD_LIBRARY_PATH should preferably only contain entries related to slurm scheduler.

```sh
exit #from sumner

## login again
ssh login.sumner.jax.org
```

*   Check common env variables set by default (HPC team)

```sh
## paths where all executables can be found
echo $PATH
```

```
/cm/local/apps/gcc/8.2.0/bin:/cm/shared/apps/slurm/18.08.8/sbin:/cm/shared/apps/slurm/18.08.8/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:.:/home/yoda/.local/bin:/home/yoda/bin
```

```sh
## paths where shared libraries are available to run programs
echo $LD_LIBRARY_PATH
```

```
/cm/local/apps/gcc/8.2.0/lib:/cm/local/apps/gcc/8.2.0/lib64:/cm/shared/apps/slurm/18.08.8/lib64/slurm:/cm/shared/apps/slurm/18.08.8/lib64
```

```sh
## Used by gcc before compiling program
## Read https://stackoverflow.com/a/4250666/1243763 
echo $LIBRARY_PATH
```

```
/cm/shared/apps/slurm/18.08.8/lib64/slurm:/cm/shared/apps/slurm/18.08.8/lib64
```

```sh
## default loaded modules
## Most of paths in PATH, LD_LIBRARY_PATH, and LIBRARY_PATH are configured by these loaded modules.
module list
```

>Currently Loaded Modules:
>  1) shared   2) DefaultModules   3) dot   4) default-environment   5) slurm/18.08.8   6) gcc/8.2.0

*   Store default hpc configuration

>Useful to fall back to HPC defaults if something goes awry!

```sh
mkdir -p ~/bkup/confs/hpc_default_env/

cp .bashrc bkup/confs/hpc_default_env/
cp .bash_profile bkup/confs/hpc_default_env/

## export global env
env | tee -a ~/bkup/confs/hpc_default_env/default_hpc_env.txt
```

*   `dot` module only appends `.` to PATH variable (see `module show dot`), so that you do not need to prefix `./` to run an executable file under present working directory. Since I do not need `dot` module, I will override default module loading by doing `module unload dot` in my bash configuration (later). 

```sh
module list
```

*   For now, you may add following cmd to your `~/.bash_profile`. Eventually it will go to `~/.profile.d/` setup detailed below.

```sh
module unload dot
```

*   For now, I do not need system gcc and will rely on conda-installed gcc and other devtools `x86_64-conda_cos6-linux-gnu-*`. More on that later but let's unload gcc first.

```sh
module unload gcc
module list
```

```
Currently Loaded Modules:
  1) shared   2) DefaultModules   3) default-environment   4) slurm/18.08.8
```

!!! notice "Unloading gcc"
    Note that while starting pseudo-terminal using screen, tmux, or slurm interactive job, you may get module loaded gcc again in PATH. If so, **make sure to do** `module unload gcc` before running setup further.

## Backup and Reset Dotfiles

*   Move dotfiles to archived directory

>If you have dotfiles and/or dot directories like .Renviron, .Rprofile, .curlrc, .cache, .config, etc., that may cause issues configuring environment.

!!! danger ":skull_and_crossbones: Moving dotfiles :skull_and_crossbones:"
    Following is what I've done but may not be safe unless you know what you are doing! Moving some of dotfiles is tricky as they are required for login to sumner. If you are doing this, **make sure NOT to logout** of sumner and at the end of executing this code block on sumner, make sure that you can login from another terminal to sumner.

```sh
## WARN: Moving all files and directories starting
## with dot to archived dir.
mkdir -p "${HOME}"/legacy_env && \
mv "${HOME}"/.[^.]* legacy_env/

## DO NOT FORGET TO COPY BACK following files to
## "${HOME}"/ else you may get locked out of sumner.

cd "${HOME}" && \
echo "You are in home directory at $(pwd)"

## sumner ssh dir
rsync -avhP legacy_env/.ssh ./

## sumner login tokens, if any
cp legacy_env/.vas_* ./
cp legacy_env/.bash* ./
cp legacy_env/.ksh* ./
cp legacy_env/.k5login ./
rsync -avhP legacy_env/.pki ./
rsync -avhP legacy_env/.parallel ./

## optional files, if any
## singularity may take a larger space 
rsync -avhP legacy_env/.singularity ./

rsync -avhP legacy_env/.subversion ./
cp legacy_env/.emacs ./
cp legacy_env/.viminfo ./

## make empty dirs
## note that user .local and .config, if any are now backed up and
## we are creating a empty ~/.local directory
mkdir -p "${HOME}"/.cache
mkdir -p "${HOME}"/.config
mkdir -p "${HOME}"/.local

## CONFIRM FROM A SEPARATE TERMINAL that you can login to sumner
ssh yoda@sumner
env
```

*   If above command succeeds and env looks similar (PATH in particular) to PATH and LD_LIBRARY_PATH shown above, you're good! You can exit old sumner session and install anaconda3 in new terminal session.

!!! info "Start Interactive Job prior to installation"
    Prefer running setup on a dedicated interactive node instead of login node. Some of conda install/update steps may get killed on login node.

    ```sh
    srun -p compute -q batch -N 1 -n 3 --mem 10G -t 08:00:00 --pty bash
    ```

## Install anaconda3

!!! warning "Python3 over Python2"
    Prefer using Anaconda3 (Python3) over Python2 as the latter has reached [End of Life](https://www.python.org/doc/sunset-python-2/).

>For anaconda3: Using *v2019.03-Linux-x86_64* with [permalink](https://repo.anaconda.com/archive/Anaconda2-2019.03-Linux-x86_64.sh) and [MD5](https://docs.anaconda.com/anaconda/install/hashes/Anaconda3-2019.03-Linux-x86_64.sh-hash/): b77a71c3712b45c8f33c7b2ecade366c.

```sh
cd "$HOME" && \
mkdir -p Downloads/conda && \
cd Downloads/conda && \
wget https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh && \
md5sum Anaconda3-2019.10-Linux-x86_64.sh
```

*   Setup anaconda3 environment with default options, i.e., install at `~/anaconda3`.

```sh
cd "$HOME" && \
bash ~/Downloads/conda/Anaconda3-2019.10-Linux-x86_64.sh
```

*   Once conda installation is complete at default location, logout and login to sumner. Default conda env, `base` will now be in effect. Note `(base)` prefix to your username. Also, check output of following:

```sh
echo $CONDA_DEFAULT_ENV
```

>base

```sh
echo $CONDA_PREFIX
```

>/home/yoda/anaconda3

## Configuring Conda

Following are additional configuration within conda environment to enable installation of R 3.6.1+ and Jupyter.

### Set channel priority

!!! important
    Prefer installing compilers only from a single channel and avoid mix-and-match install. Read more at [conda-forge page](https://conda-forge.org/docs/user/tipsandtricks.html) on `channel_priority: strict` which is enabled at default for conda v4.6 or higher.

*   Add Bioconda and conda-forge channels to get updated and compbio related packages. Avoid changing order of following commands unless you prefer to keep a different priority for these channels.

```sh
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
```

*   Above command will generate `~/.condarc` file and set priority for channels, i.e., when same package is available from more than one channels, we prioritize installation per ordered channel list in `~/.condarc` file as shown below. This file should be present after above commands and no need to edit unless changing priority of channels.

>This is in yaml format file. Please take care of preceding spaces (and not tabs) before and after `-` while editing this file.

```
channels:
  - conda-forge
  - bioconda
  - defaults
```

### Install R 3.6.1

*   For compatibility with conda env, prefer installing R 3.6 via conda.

*   Prefer installing R env from `conda-forge` channel which is already a priority channel in our `~/.condarc`. We also specify R version, just to make sure that we install R v3.6.1.

!!! bug "Beware of non-standard conda packages"
    Note that most up-to-date R version may be available in the same or other conda channels, like `r` or `bioconda` but it is preferable to install R from the first priority channel, i.e., `conda-forge` in our case, and where package does not show non-standard labels at anaconda website, e.g., As of writing this section, R 3.6.2 on [anaconda website](https://anaconda.org/conda-forge/r-base) shows use of non-standard labels, most likely because it was updated a few days before and so, may not comply with all of conda dependency.

```sh
## look for a line r-base and check source channel.
## If it is other than conda-forge, try to downgrade R package where
## r-base is available under conda-forge channel.
conda install -c conda-forge r-base=3.6.1
```

*   Above command will take 15-30 min to resolve dependencies. It will do **major overhaul** of default conda environment by...
    *   upgrading conda to latest version, 4.8.2 or higher.
    *   installing conda and r-base from conda-forge source.
    *   and much more...

#### Pin R and conda auto-updates

*   Before moving further, let's [pin R version](https://stackoverflow.com/a/48733093/1243763 "how to fix software versions in conda environment - stackoverflow") to 3.6.1 and also disallow conda auto-updates. That way, we have lesser chances of breaking conda env when we do `conda install <pkg>` in future, and carefully install/update packages without breaking existing setup.

!!! tip "Compile over `conda install Rpkg`"
    Typically, I avoid installing or updating package if `conda install` throws a message or warning about **removing or downgrading** existing packages. In such cases, I fall back to compiling package using available devtools in conda and sumner. Also, I load compiled package using *Modulefile* when needed, and not integrate it in my default bash environment as this may give errors while running some random program due to conflicts in shared library versions.

```sh
conda config --set auto_update_conda False

## add following to pinned file
nano ~/anaconda3/conda-meta/pinned
```

>r-base ==3.6.1

#### Setup Rprofile and Renviron

*   Setup R package directory path for R 3.6

```sh
mkdir -p ~/R/pkgs/v3.6
```

*   Create these two files to setup startup env for R

*   Renviron

```sh
nano ~/.Renviron
```

!!! tip "Where should R save new packages?"
    Over time, this directory may grow in size, so better to keep under tier1 storage.

```sh
R_LIBS="/projects/verhaak-lab/yoda/sumnerenv_os7/R/pkgs/v3.6:/home/yoda/R/pkgs/v3.6:/home/yoda/anaconda3/lib/R/library"
```

>You can confirm precedence of R library paths in R using `.libPaths()` command. Note that */home/yoda/anaconda3/lib/R/library* is a required path set while installing R using conda.

*   R profile

```sh
nano ~/.Rprofile
```

```
## set user specific env variables, if any here
## e.g., GITHUB_PAT if here
Sys.setenv("GITHUB_PAT"="xyzabc1234")

## Default source to download packages
local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cran.rstudio.com"
  options(repos = r)
})
```

*   Before further configuring sumner env, let's logout and login first from interactive job and exit sumner. Then, login back to sumner and start interactive queue again.

```sh
exit # from interactive session
exit # from sumner

ssh sumner

## start interactive session
srun -p compute -q batch -N 1 -n 3 --mem 10G -t 08:00:00 --pty bash
```

*   Confirm that login env is similar to earlier env (just after anaconda3 setup) by running `env` command. PATH should now have paths related to conda env **prefixed** but nothing else related to modules, LD_LIBRARY_PATH, etc.

Also, make sure that module: gcc is unloaded. We do not want system gcc (or any other devtools), and instead rely on conda-installed devtools.

```sh
## unload gcc if loaded
module unload gcc

## example PATH variable
/home/yoda/anaconda3/bin:/home/yoda/anaconda3/condabin:/cm/shared/apps/slurm/18.08.8/sbin:/cm/shared/apps/slurm/18.08.8/bin
:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/yoda/.local/bin:/home/yoda/bin
```

!!! tip "Avoid Rpkgs using `conda install`" 
    Install essential R packages and jupyter kernel for R **only if** they are available for R 3.6.x (preferably v3.6.1) from conda-forge channel. This may not be a case for most times, e.g., for R v3.5.1, I can find compatible packages but not for R 3.6. I avoid downloading `r-essentials` from other channels, including `r` as some packages have dependencies on shared library which are different between `r` and `conda-forge` channel. I prefer installing R packages using `install.packages`, `devtools::install_github()` or `BiocManager` command in R.

```sh
## This did not work for R 3.6.1
# conda install -c conda-forge r-essentials
```

#### Installing R and linux packages

Here, I alternate between R and bash to install packages I use on regular basis. It is going to take a while to install these packages. You may not need to install all packages but if you are skipping ahead and get into error because of missing library, package, etc., you probably need to revisit this code block and confirm that you have all of dependencies in your environment for successful installation.

```r
install.packages("devtools")
```

>When you start installing R packages, notice `x86_64-conda_cos6-linux-gnu-cc` or other compilers that R is using instead of `/usr/bin/gcc` or sumner-defaults. Similarly, during loading R packages which requires shared libraries, we link shared libs from conda and not from system-defaults (gcc and others). That's one of reasons I did `module unload gcc` before installing R packages. Eventually, we will set **~/.profile.d** environment such that it will always load conda environment and ignore gcc and other devtools from system paths. 

!!! danger ":skull_and_crossbones: :construction: Work In Progress :construction: :skull_and_crossbones:"
    Documentation is in alpha stage and not intended for setting up Sumner HPC environment.

***

### Backup conda env

*   Base environment.

```sh
## script is on github repo under conds/bin/
./conda_bkup.sh
```
