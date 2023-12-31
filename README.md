# nci-scripts

PBS scripts for running nanopore genomics analyses on Australia's [NCI Gadi Supercomputer](https://nci.org.au/our-systems/hpc-systems).

These scripts use software installed under the [if89 project (Australian BioCommons Tools and Workflows project)](https://australianbiocommons.github.io/ables/if89/).  If you have an NCI account, simply join the if89 project using the [myNCI](https://my.nci.org.au/mancini/login?next=/mancini/) and start using these scripts with software already installed on Gadi through project if89.  

See the comments in the scripts to identify which variables you should change.

## S/BLOW5 Basecalling

- [basecall/buttery-eel.pbs.sh](basecall/buttery-eel.pbs.sh) - Basecall a S/BLOW5 file using [buttery-eel](https://github.com/Psy-Fer/buttery-eel) wrapper for Guppy.
- [basecall/slow5-dorado.pbs.sh](basecall/slow5-dorado.pbs.sh) - Basecall a S/BLOW5 file using [slow5-dorado](https://github.com/hiruna72/slow5-dorado/releases/), a fork of ONT's Dorado that supports S/BLOW5.

## S/BLOW5 Modification calling

- [modcall/f5c-call-methylation.pbs.sh](modcall/f5c-call-methylation.pbs.sh) - Perform methylation calling of a S/BLOW5 file using [f5c](https://github.com/hasindu2008/f5c/), a GPU accelerated version of nanopolish. You must execute `f5c-index.pbs.sh` under the preparation section first.

## Read Alignment

- [align/minimap2-samtools.pbs.sh](align/minimap2-samtools.pbs.sh) - Align a FASTQ file to a reference using Minimap2 and sort using samtools to create a BAM file (and the BAM index).

## Preparation

- [prep/f5c-index.pbs.sh](prep/f5c-index.pbs.sh) - Perform f5c index (required before running f5c call-methylation or eventalign).

## Data Transfer

- [transfer/s3-download.pbs.sh](transfer/s3-download.pbs.sh) - Download an example BLOW5 file and an index from an S3 bucket using aws cli.
