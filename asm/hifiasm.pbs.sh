#!/bin/bash
#PBS -P ox63
#PBS -q normal
#PBS -N hifiasm
#PBS -l walltime=12:00:00
#PBS -l storage=gdata/ox63+scratch/ox63+scratch/if89+gdata/if89
#PBS -l mem=192GB
#PBS -l ncpus=48
#PBS -l wd

###################################################################

###################################################################

# Make sure to change:
# 1. ox63 to your own projects

# to run:
# qsub -v FASTQ=/path/to/reads.fastq,OUT_PREFIX=hg002 ./hifiasm.pbs.sh

###################################################################

usage() {
	echo "Usage: qsub -v FASTQ=/path/to/reads.fastq,OUT_PREFIX=hg002 ./hifiasm.pbs.sh" >&2
	echo
	exit 1
}

#output prefix
[ -z "${OUT_PREFIX}" ] && usage
#fastq
[ -z "${FASTQ}" ] && usage


# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

module load /g/data/if89/apps/modulefiles/hifiasm/0.19.8 || die "hifiasm not found"
THREADS=${PBS_NCPUS}

#########################################

## generate assembly with hifiasm
/usr/bin/time -v hifiasm -t ${THREADS} --hg-size 3g -o ${OUT_PREFIX} ${FASTQ} || die "hifiasm failed"


