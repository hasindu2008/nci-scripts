# nci-scripts

PBS scripts for running nanopore genomics analyses on Australia's [NCI Gadi Supercomputer](https://nci.org.au/our-systems/hpc-systems).

These scripts uses software installed under the if89 project. If you have an NCI account, simply join the if89 project using the [myNCI](https://my.nci.org.au/mancini/login?next=/mancini/) and start using these scripts with software already installed on Gadi through project if89. See the comments in the scripts to identify which variables you should change.

## S/BLOW5 Basecalling

- [basecall/buttery-eel.pbs.sh](basecall/buttery-eel.pbs.sh) - Basecall a S/BLOW5 file using [buttery-eel](https://github.com/Psy-Fer/buttery-eel) wrapper for Guppy
- [basecall/slow5-dorado.pbs.sh](basecall/slow5-dorado.pbs.sh) - Basecall a S/BLOW5 file using [slow5-dorado](https://github.com/hiruna72/slow5-dorado/releases/), a fork of ONT's Dorado that supports S/BLOW5.
