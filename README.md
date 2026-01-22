# nci-scripts

Example PBS scripts for running long read genomics analyses on Australia's [NCI Gadi Supercomputer](https://nci.org.au/our-systems/hpc-systems).

These scripts use software installed under the [if89 project (Australian BioCommons Tools and Workflows project)](https://australianbiocommons.github.io/ables/if89/).  With your NCI account, simply join the if89 project using the [myNCI](https://my.nci.org.au/mancini/login?next=/mancini/) and start using these scripts with software already installed on Gadi through project if89.

See the comments in the scripts to identify which variables you should change. These scripts are intentionally kept minimal as they are intended to serve as examples for you to quickly get started.

Please note that the tool versions in the scripts may not always be the latest, as I only update them periodically. You may update the scripts when newer tool versions are available.

## Read Alignment

- [align/minimap2-samtools.pbs.sh](align/minimap2-samtools.pbs.sh) - Align a FASTQ file to a reference using Minimap2 and sort using samtools to create a BAM file (and the BAM index).

## Assembly

- [asm/hifiasm.pbs.sh](asm/hifiasm.pbs.sh) - assemble a genome using hifiasm
- [asm/quast.pbs.sh](asm/quast.pbs.sh) - evaluate a assembly using quast

## S/BLOW5 Basecalling

- [basecall/slow5-dorado.pbs.sh](basecall/slow5-dorado.pbs.sh) - Basecall a S/BLOW5 file using [slow5-dorado](https://github.com/hiruna72/slow5-dorado/releases/). slow5-dorado is a fork of ONT's Dorado that supports S/BLOW5. This script is for slow5-dorado >= v1 and supports latest R10.4.1 5KHz data only. For old data (DNA R10.4.1 4kHz, DNA R9.4.1 and RNA002) please use [this](basecall/archived/slow5-dorado-0.9.6.pbs.sh).
- [basecall/buttery-eel-dorado.pbs.sh](basecall/buttery-eel-dorado.pbs.sh) - Basecall a S/BLOW5 file using [buttery-eel](https://github.com/Psy-Fer/buttery-eel) wrapper for Dorado. This script is for ont-dorado-server >= 7.11.2 and supports latest R10.4.1 5KHz data only. For old data (DNA R10.4.1 4kHz, DNA R9.4.1, and RNA002), use [this](basecall/archived/buttery-eel-0.5.1+dorado7.4.12.pbs.sh). For legacy Guppy basecaller, use [this](basecall/archived/buttery-eel-guppy.pbs.sh).


## S/BLOW5 Modification calling

- [modcall/f5c-call-methylation.pbs.sh](modcall/f5c-call-methylation.pbs.sh) - Perform methylation calling of a S/BLOW5 file using [f5c](https://github.com/hasindu2008/f5c/), a GPU accelerated version of nanopolish. You must execute `f5c-index.pbs.sh` under the preparation section first.
- [modcall/slow5-dorado.pbs.sh](modcall/slow5-dorado.pbs.sh) - Modification calling of a S/BLOW5 file using [slow5-dorado](https://github.com/hiruna72/slow5-dorado/releases/). slow5-dorado is a fork of ONT's Dorado that supports S/BLOW5. This script is for slow5-dorado >= v1 and supports latest R10.4.1 5KHz data only. For old data (DNA R10.4.1 4kHz, DNA R9.4.1 and RNA002) please use  [this](modcall/archived/slow5-dorado-0.9.6.pbs.sh)
- [modcall/buttery-eel-dorado.pbs.sh](modcall/buttery-eel-dorado.pbs.sh) - Modification calling of a S/BLOW5 file using [buttery-eel](https://github.com/Psy-Fer/buttery-eel) wrapper for Dorado. This script is for ont-dorado-server >= 7.11.2 and supports latest R10.4.1 5KHz data only. For older data (DNA R10.4.1 4kHz, DNA R9.4.1, and RNA002), use [this](modcall/archived/buttery-eel-0.5.1+dorado7.4.12.pbs.sh). For legacy Guppy, use [this](modcall/archived/buttery-eel-guppy.pbs.sh).
- [modcall/minimod.pbs.sh](modcall/minimod.pbs.sh) - Extract modification frequencies from a BAM file using [minimod](https://github.com/warp9seq/minimod).

## Preparation

- [prep/f5c-index.pbs.sh](prep/f5c-index.pbs.sh) - Perform f5c index (required before running f5c call-methylation or eventalign).
- [prep/pod5-to-merged-blow5.pbs.sh](prep/pod5-to-merged-blow5.pbs.sh) - Converts a POD5 data set to a single merged BLOW5 file using [blue-crab](https://github.com/Psy-Fer/blue-crab) and [slow5tools](https://github.com/hasindu2008/slow5tools)

## Data Transfer

- [transfer/s3-download.pbs.sh](transfer/s3-download.pbs.sh) - Download an example BLOW5 file and an index from an S3 bucket using aws cli.

## Misc
.
- [misc/reduce-blow5.pbs.sh](misc/reduce-blow5.pbs.sh) - Lossy compression a given BLOW5 file
