#!/bin/bash
#PBS -P ox63
#PBS -N MINIMOD
#PBS -q normal
#PBS -l ncpus=16
#PBS -l mem=64GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+gdata/ox63

###################################################################

###################################################################

# Make sure to change:
# 1. ox63 to your own projects

# to run:
# qsub -v REF=/path/to/ref.fa,BAM=/path/to/reads.bam,OUT_DIR=/path/to/outdir ./minimod.pbs.sh

###################################################################

usage() {
	echo "Usage: qsub -v REF=/path/to/ref.fa,BAM=/path/to/reads.bam,OUT_DIR=/path/to/outdir ./minimod.pbs.sh" >&2
	echo
	exit 1
}

#directory where output should be written to
[ -z "${OUT_DIR}" ] && usage
#bam
[ -z "${BAM}" ] && usage
#ref
[ -z "${REF}" ] && usage

module load /g/data/if89/apps/modulefiles/minimod/0.4.0

###################################################################

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

minimod --version || die "Could not find minimod"

test -d ${OUT_DIR} && die "Output directory ${OUT_DIR} already exists. Please delete it first or give an alternate location. Exiting."

test -e ${BAM} || die "${BAM} not found. Exiting."
test -e ${REF} || die "${REF} not found. Exiting."

mkdir ${OUT_DIR} || die "Creating directory ${OUT_DIR} failed. Exiting."
cd ${OUT_DIR} || die "${OUT_DIR} not found. Exiting."

/usr/bin/time -v minimod freq ${REF} ${BAM} -t 16 -o ${OUT_DIR}/freq.tsv 2> ${OUT_DIR}/freq.stderr 1> ${OUT_DIR}/freq.stdout || die "minimod freq failed."

echo "alignment success"
