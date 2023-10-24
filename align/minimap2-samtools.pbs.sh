#!/bin/bash
#PBS -P wv19
#PBS -N MINIMAP2_SAMTOOLS
#PBS -q normal
#PBS -l ncpus=16
#PBS -l mem=64GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+scratch/wv19+gdata/wv19+gdata/ox63

###################################################################

###################################################################

# Make sure to change:
# 1. wv19 abd ox63 to your own projects

# to run:
# qsub -v REF=/path/to/ref.fa,FASTQ=/path/to/reads.fastq,OUT_DIR=/path/to/outdir ./minimap2_samtools.pbs.sh

###################################################################

usage() {
	echo "Usage: qsub -v REF=/path/to/ref.fa,FASTQ=/path/to/reads.fastq,OUT_DIR=/path/to/outdir ./minimap2_samtools.pbs.sh" >&2
	echo
	exit 1
}

#directory where BAM output should be written to
[ -z "${OUT_DIR}" ] && usage
#fastq
[ -z "${FASTQ}" ] && usage
#ref
[ -z "${REF}" ] && usage

module load minimap2/2.24
module load samtools/1.12

###################################################################

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

minimap2 --version || die "Could not find minimap2"
samtools --version || die "Could not find samtools"

test -d ${OUT_DIR} && die "Output directory ${OUT_DIR} already exists. Please delete it first or give an alternate location. Exiting."

test -e ${FASTQ} || die "${FASTQ} not found. Exiting."
test -e ${REF} || die "${REF} not found. Exiting."

mkdir ${OUT_DIR} || die "Creating directory ${OUT_DIR} failed. Exiting."
cd ${OUT_DIR} || die "${OUT_DIR} not found. Exiting."

/usr/bin/time -v minimap2 -ax map-ont ${REF} ${FASTQ} -t 16 --secondary=no | samtools sort - -T ${OUT_DIR}/ -o ${OUT_DIR}/reads.bam || die "alignment failed"
/usr/bin/time -v samtools index ${OUT_DIR}/reads.bam || die "index failed"

echo "alignment success"
