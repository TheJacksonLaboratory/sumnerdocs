---
title: "How To Run Snakemake"
authors: "Samir B. Amin @sbamin"
---

## Toy example

Compliant with JAX HPC Sumner (Cent OS7) using slurm v18.08.8 and [Snakemake v5.14.0](https://snakemake.readthedocs.io/en/v5.14.0/)

#### Setup

*   `ssh sumner` and clone [TheJacksonLaboratory/toymake](https://github.com/TheJacksonLaboratory/toymake) repository.

```sh
mkdir -p ~/pipelines/snakemake
cd ~/pipelines/snakemake

git clone git@github.com:TheJacksonLaboratory/toymake.git
cd toymake
```

*   Edit [config.yaml](https://github.com/TheJacksonLaboratory/toymake/blob/master/config.yaml) to match your username and valid path for `smk_home` (where snakemake code resides, typically tier1 space) and `workdir` (where snakemake output will be stored, typically scratch space).

*   Edit [Snakefile](https://github.com/TheJacksonLaboratory/toymake/blob/master/Snakefile) to match your username.

*   Setup slurm profile for snakemake. [Read details here first](https://github.com/Snakemake-Profiles/slurm)

```sh
mkdir -p ~/.config/snakemake/sumner/
rsync -avhP ~/pipelines/snakemake/toymake/profile/sumner/ ~/.config/snakemake/sumner/
```

* To modify job resources, [edit config/slurm_sumner_defaults.yaml](https://github.com/TheJacksonLaboratory/toymake/blob/master/config/slurm_sumner_defaults.yaml)

#### Order of Precedence for `sbatch` arguments

Arguments to `sbatch` takes precedence in the following order (lowest to highest priority) and must be named according to
==[sbatch long option names](https://slurm.schedmd.com/sbatch.html)==. Please [read details here first](https://github.com/Snakemake-Profiles/slurm).

1. `sbatch_defaults` in [~/.config/snakemake/sumner/slurm-submit.py](https://github.com/TheJacksonLaboratory/toymake/blob/master/profile/sumner/slurm-submit.py)
2. Profile `cluster_config` file `__default__` entries from [config/slurm_sumner_defaults.yaml](https://github.com/TheJacksonLaboratory/toymake/blob/master/config/slurm_sumner_defaults.yaml)
3. [Snakefile](https://github.com/TheJacksonLaboratory/toymake/blob/master/Snakefile) threads and resources (time, mem_mb)
4. Profile `cluster_config` file `<rulename>` entries from [config/slurm_sumner_defaults.yaml](https://github.com/TheJacksonLaboratory/toymake/blob/master/config/slurm_sumner_defaults.yaml)
5. `--cluster-config` parsed to Snakemake: Avoid this as it is deprecated since Snakemake 5.10.

### Run workflow

*   [run_snakemake.sh](https://github.com/TheJacksonLaboratory/toymake/blob/master/run_snakemake.sh) is a wrapper around `snakemake` command. It exports environment variables, ==SMKDIR== and ==WORKDIR==, which are internally used by sumner slurm profile at *~/.config/snakemake/sumner/*

```sh
./run_snakemake.sh
```

* Expected output

![Expected output](/assets/images/slurm_snakemake_output.png "Expected output")

## Credits

*   [Snakemake-Profiles/slurm](https://github.com/Snakemake-Profiles/slurm) by [Per Unneberg](https://github.com/percyfal) 
*   [Variant of Snakemake slurm profile](https://github.com/bnprks/snakemake-slurm-profile) by [Ben Parks](https://github.com/bnprks)
