---
title: "How to run VEP using singularity"
---

>For HPC Sumner at [JAX](https://jax.org)  
>@sbamin  

### Install VEP via docker

*   Download [docker image for vep](https://hub.docker.com/r/ensemblorg/ensembl-vep) and convert to singularity .sif format

```sh
## v99.2 but may vary for future dates
singularity run ensembl-vep_latest
```

*   Converted image should be under followig path.

```sh
find "$SINGULARITY_CACHEDIR" -type f -name "ensembl-vep_latest.sif"
```

>I've copied converted sif images to a separate directory and exported directory path as `SINGULARITY_SIF` env variable. I've renamed *ensembl-vep_latest.sif* to *ensembl-vep_v99.2.sif*.

### Download offline VEP cache

*   To speed up annotations, download vep cache **matching** vep version downloaded earlier, i.e., v99. [See details](https://useast.ensembl.org/info/docs/tools/vep/script/vep_cache.html) for downloading cache.
*   cache size can go in several GBs, so save under tier1.

```sh
cd "$RVANNOT"/vep_core/v99

curl -O ftp://ftp.ensembl.org/pub/release-99/variation/indexed_vep_cache/homo_sapiens_vep_99_GRCh38.tar.gz

## approx. 14GB
## MD5: a2a8edfe72ffa659242e66d414027701  homo_sapiens_vep_99_GRCh38.tar.gz
## extract cache
tar xzf homo_sapiens_vep_99_GRCh38.tar.gz
```

#### IMPORTANT: Using hg19/GRCh37

*   If VCFs for annotations require `hg19/GRCh37` assembly, you need to install valid cache for Grch37 assembly. [Read discussion here](https://github.com/Ensembl/ensembl-vep/issues/407).

```sh
cd "$RVANNOT"/vep_core/v99

curl -O ftp://ftp.ensembl.org/pub/release-99/variation/indexed_vep_cache/homo_sapiens_vep_99_GRCh37.tar.gz

## approx. 13GB
## MD5: 72928de96075666a4477cbd4430084c9  homo_sapiens_vep_99_GRCh37.tar.gz
## extract cache
tar xzf homo_sapiens_vep_99_GRCh37.tar.gz
```

### Run VEP in offline mode

* Use downloaded cache instead of running in `--database` mode. The latter will fetch data from online Ensemble database and can be very slow.
* For detailed arguments, [read VEP manpage](https://useast.ensembl.org/info/docs/tools/vep/script/vep_options.html)
*   **NOTE:** Using `--assembly GRCh37` here for hg19 coordinates. Omitting it will default to the most current assembly, GRCh38.

```sh
singularity run "${SINGULARITY_SIF}"/ensembl-vep_v99.2.sif vep --offline --dir_cache "${RVANNOT}/vep_core/v99" --species homo_sapiens --assembly GRCh37 --compress_output gzip -o ffe4bb51-e98a-41a7-a4e1-c3970386889c.consensus.20160830.somatic.snv_mnv.vep.vcf.gz -i /projects/verhaak-lab/ecdna/datasets/pcawg/dump/final_consensus_12oct/icgc/snv_mnv/ffe4bb51-e98a-41a7-a4e1-c3970386889c.consensus.20160830.somatic.snv_mnv.vcf.gz

singularity run "${SINGULARITY_SIF}"/ensembl-vep_v99.2.sif vep --offline --dir_cache "${RVANNOT}/vep_core/v99" --species homo_sapiens --assembly GRCh37 --compress_output gzip -o ffe4bb51-e98a-41a7-a4e1-c3970386889c.consensus.20161006.somatic.indel.vep.vcf.gz -offline -i /projects/verhaak-lab/ecdna/datasets/pcawg/dump/final_consensus_12oct/icgc/indel/ffe4bb51-e98a-41a7-a4e1-c3970386889c.consensus.20161006.somatic.indel.vcf.gz
```

_END_
