---
title: "How to run VEP using singularity"
authors: Samir B. Amin, @sbamin
---

[![https://badgen.net/badge/singularity/JAXhub/green](https://badgen.net/badge/singularity/JAXhub/blue)](https://jaxreg.jax.org/collections/21) [![https://badgen.net/badge/vep/v99.2/green](https://badgen.net/badge/vep/v99.2/green)](https://jaxreg.jax.org/containers/203) [![https://badgen.net/badge/vcf2maf/v1.0_a071af6/green](https://badgen.net/badge/vcf2maf/v1.0_a071af6/green)](https://jaxreg.jax.org/containers/205)

### Install VEP via docker

*   Download [docker image for vep](https://hub.docker.com/r/ensemblorg/ensembl-vep) and convert to singularity .sif format

```sh
## v99.2 but may vary for future dates
singularity run docker://ensemblorg/ensembl-vep:latest
## OR specific version
singularity run docker://ensemblorg/ensembl-vep:release_99.2
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

!!! IMPORTANT "Using hg19/GRCh37"
    If VCFs for annotations require `hg19/GRCh37` assembly, you need to install valid cache for Grch37 assembly. [Read discussion here](https://github.com/Ensembl/ensembl-vep/issues/407).

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
singularity run "${SINGULARITY_SIF}"/ensembl-vep_v99.2.sif vep --offline --vcf --dir_cache "${RVANNOT}/vep_core/v99" --species homo_sapiens --assembly GRCh37 -o ffe4bb51-e98a-41a7-a4e1-c3970386889c.consensus.20160830.somatic.snv_mnv.vep.vcf -i /projects/verhaak-lab/ecdna/datasets/pcawg/dump/final_consensus_12oct/icgc/snv_mnv/ffe4bb51-e98a-41a7-a4e1-c3970386889c.consensus.20160830.somatic.snv_mnv.vcf.gz

singularity run "${SINGULARITY_SIF}"/ensembl-vep_v99.2.sif vep --offline --vcf --dir_cache "${RVANNOT}/vep_core/v99" --species homo_sapiens --assembly GRCh37 -o ffe4bb51-e98a-41a7-a4e1-c3970386889c.consensus.20161006.somatic.indel.vep.vcf -offline -i /projects/verhaak-lab/ecdna/datasets/pcawg/dump/final_consensus_12oct/icgc/indel/ffe4bb51-e98a-41a7-a4e1-c3970386889c.consensus.20161006.somatic.indel.vcf.gz
```

### How to run vcf2maf

*   If you are running vcf2maf, it needs input vcf in uncompressed format. vcf2maf will internally run `vep`, so you may not need to run vep separately.

!!! warning "Read manual before running container"
    Review how-to-run details at [mskcc/vcf2maf](https://github.com/mskcc/vcf2maf) and by reading manpage. You may endup getting **incorrectly parsed maf** if certain parameters are not specified per requirement, e.g., `--tumor-id` and `--normal-id` requirements for vcfs with tumor, normal samples.

```sh
singularity exec "${SINGULARITY_SIF}"/vcf2maf_v1.0_a071af6.sif /opt/vcf2maf/vcf2maf.pl --help
```

*   vcf2maf requires several dependencies. If you get an error, [check out this detailed guide](https://gist.github.com/ckandoth/5390e3ae4ecf182fa92f6318cfa9fa97). If error persists, please [search and/or submit an issue at mskcc/vcf2maf](https://github.com/mskcc/vcf2maf/issues).

```sh
VEP_DIR=/opt/vep/src/ensembl-vep
VEP_DATA="${RVANNOT}"/vep_core/v99
REF_FASTA=/projects/verhaak-lab/hg19broad/Homo_sapiens_assembly19.fasta
EXAC_VCF=/projects/verhaak-lab/verhaak_env/core_annots/exac/ExAC_nonTCGA.r0.3.1.sites.vep.vcf.gz

export VEP_DIR VEP_DATA REF_FASTA EXAC_VCF
```

*   In contrast to singularity vep image, note the use of singularity exec and not singularity run command for singularity vcf2maf image.
*   Note that this example does NOT use --tumor-id and --normal-id parameters as vcf does not have those columns. However, this may not be a case for vcf output from common somatic callers, like mutect2, varscan2, etc.
*   Increasing vcf-forks more than 4 does not improve conversion exponentially, so there may not be need of increasing threads.

```sh
singularity exec "${SINGULARITY_SIF}"/vcf2maf_v1.0_a071af6.sif /opt/vcf2maf/vcf2maf.pl \
--vep-path "${VEP_DIR}" \
--vep-data "${VEP_DATA}" \
--ref-fasta "${REF_FASTA}" \
--filter-vcf "${EXAC_VCF}" \
--vep-forks 4 \
--species homo_sapiens \
--ncbi-build GRCh37 \
--input-vcf ffe4bb51-e98a-41a7-a4e1-c3970386889c.consensus.20160830.somatic.snv_mnv.vcf \
--output-maf ffe4bb51-e98a-41a7-a4e1-c3970386889c.consensus.20160830.somatic.snv_mnv.maf
```

_END_
