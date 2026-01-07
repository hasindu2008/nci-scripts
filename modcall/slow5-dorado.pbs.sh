#!/bin/bash
#PBS -P ox63
#PBS -N SLOW5-DORADO
#PBS -q gpuvolta
#PBS -l ncpus=48
#PBS -l ngpus=4
#PBS -l mem=384GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+scratch/wv19+gdata/wv19+scratch/ox63+gdata/ox63

###################################################################

# slow5-dorado v1.1.1
# Note: Dorado v1.0.0 and above only supports R10.4.1 5KHz data and newer.
#
# if you want to use basecalling models for older data (DNA R10.4.1 4kHz, DNA R9.4.1, and RNA002)
# please use the script slow5-dorado-0.9.6.pbs.sh instead.
#

MODEL_DIR=/g/data/if89/apps/slow5-dorado/1.1.1/slow5-dorado/models/

#R10.4.1 5KHz
MODEL=${MODEL_DIR}/dna_r10.4.1_e8.2_400bps_sup@v5.2.0
# MODEL=${MODEL_DIR}/dna_r10.4.1_e8.2_400bps_hac@v5.2.0

###################################################################

# Make sure to change:
# 1. wv19 and ox63 to your own projects
# 2. the name of the Model
# 3. optionally, you can select a different GPU queue instead of the default V100 queue.
#     - if you want to use the H200 GPU queue, change "gpuvolta" to "gpuhopper"
#     - if you want to use the A100 GPU queue, change "gpuvolta" to "dgxa100" and the number of CPUs to 64 (dgxa100 requires at least 16 CPUs per GPU)

# to run:
# qsub -v MERGED_SLOW5=/path/to/reads.blow5,BASECALL_OUT=/path/to/out/dir ./slow5-dorado.pbs.sh

###################################################################

usage() {
	echo "Usage: qsub -v MERGED_SLOW5=/g/data/ox63/slow5-testdata/hg2_prom_lsk114_5khz_subsubsample/PGXXXX230339_reads_20k.blow5,BASECALL_OUT=/scratch/wv19/hg1112/tmp/hg2_prom_lsk114_subsubsample/ ./slow5-dorado.pbs.sh" >&2
	echo
	exit 1
}

# directory where basecalls should be written to
[ -z "${BASECALL_OUT}" ] && usage
#where the merged BLOW5 file is
[ -z "${MERGED_SLOW5}" ] && usage

module load /g/data/if89/apps/modulefiles/slow5-dorado/1.1.1
num_threads=${PBS_NCPUS}

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

test -d ${BASECALL_OUT} && die "Output directory ${BASECALL_OUT} already exists. Please delete it first or give an alternate location. Exiting."

test -e ${MERGED_SLOW5} || die "${MERGED_SLOW5} not found. Exiting."

mkdir ${BASECALL_OUT} || die "Creating directory ${BASECALL_OUT} failed. Exiting."
cd ${BASECALL_OUT} || die "${BASECALL_OUT} not found. Exiting."

/usr/bin/time -v  slow5-dorado basecaller ${MODEL} ${MERGED_SLOW5} --modified-bases 5mCG_5hmCG --models-directory ${MODEL_DIR} > reads.bam  -x cuda:all || die "Basecalling failed. Exiting."

echo "basecalling success"
