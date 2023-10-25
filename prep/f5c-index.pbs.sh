#!/bin/bash
#PBS -P wv19
#PBS -N F5C-INDEX
#PBS -q normal
#PBS -l ncpus=16
#PBS -l mem=64GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+scratch/wv19+gdata/wv19


###################################################################

###################################################################

# Make sure to change:
# 1. wv19 to your own project

# to run:
# qsub -v FASTQ=/path/to/reads.fastq,BLOW5=/path/to/reads.blow5 ./f5c-index.pbs.sh

###################################################################

usage() {
	echo "Usage: qsub -v FASTQ=/path/to/reads.fastq,BLOW5=/path/to/reads.blow5 ./f5c-index.pbs.sh" >&2
	echo
	exit 1
}

#fastq
[ -z "${FASTQ}" ] && usage
#blow5
[ -z "${BLOW5}" ] && usage

module load /g/data/if89/apps/modulefiles/f5c/1.3
num_threads=${PBS_NCPUS}

###################################################################

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

f5c --version || die "Could not find f5c"

test -e ${FASTQ} || die "${FASTQ} not found. Exiting."
test -e ${BLOW5} || die "${BLOW5} not found. Exiting."

if [ -e ${BLOW5}.idx ]; then
	echo "SLOW5 index already present, skipping it."
	/usr/bin/time -v f5c index -t ${num_threads} ${FASTQ} --slow5 ${BLOW5} --skip-slow5-idx || die "index failed"
else
	/usr/bin/time -v f5c index -t ${num_threads} ${FASTQ} --slow5 ${BLOW5} || die "index failed"
fi

echo "f5c index success"
