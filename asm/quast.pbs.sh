#!/bin/bash
#PBS -P ox63
#PBS -q normal
#PBS -N quast
#PBS -l walltime=12:00:00
#PBS -l storage=gdata/ox63+scratch/ox63+scratch/if89+gdata/if89
#PBS -l mem=64GB
#PBS -l ncpus=16
#PBS -l wd

###################################################################

###################################################################

# Make sure to change:
# 1. ox63 to your own project

# to run:
# qsub -v ASM=/path/to/asm.fasta,OUT_DIR=/path/to/dir ./quast.pbs.sh

###################################################################


usage() {
	echo "Usage: qsub -v ASM=/path/to/asm.fasta,OUT_DIR=/path/to/dir ./quast.pbs.sh" >&2
	echo
	exit 1
}

[ -z "${ASM}" ] && usage
[ -z "${OUT_DIR}" ] && usage

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

module load /g/data/if89/apps/modulefiles/quast/5.1.0rc1
THREADS=${PBS_NCPUS}

#########################################


## run quast to evaluate assemblies
quast.py -t ${THREADS} -o ${OUT_DIR} -l ${ASM} --large ${ASM} || die "quast failed"





