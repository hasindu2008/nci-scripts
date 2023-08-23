#!/bin/bash

#PBS -N AWS
#PBS -l ncpus=1
#PBS -l mem=4GB
#PBS -q copyq
#PBS -P wv19
#PBS -l walltime=10:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+scratch/wv19+gdata/wv19


###################################################################

# Make sure to change:
# wv19 to your own project

###################################################################

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

module load /g/data/if89/apps/modulefiles/aws-cli/2.13.9

aws s3 cp --no-sign-request s3://gtgseq/ont-r10-dna/NA24385/raw/PGXX22394_reads.blow5 .  || die "Downloading failed. Exiting."
aws s3 cp --no-sign-request s3://gtgseq/ont-r10-dna/NA24385/raw/PGXX22394_reads.blow5.idx .  || die "Downloading failed. Exiting."

echo "done"

