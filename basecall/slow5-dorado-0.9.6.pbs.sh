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

# slow5-dorado v0.9.6
# As stated by ONT, release 0.9.6 marks the final version of dorado (and consequently slow5-dorado),
# that will support basecalling models for older data - DNA R10.4.1 4 kHz data, DNA R9.4.1, and RNA002

MODEL_DIR=/g/data/if89/apps/slow5-dorado/0.9.6/slow5-dorado/models/

#R10.4.1 5KHz
MODEL=${MODEL_DIR}/dna_r10.4.1_e8.2_400bps_sup@v5.0.0

#R10.4.1 4KHz
# MODEL=${MODEL_DIR}/dna_r10.4.1_e8.2_400bps_sup@v4.1.0
# MODEL=${MODEL_DIR}/dna_r10.4.1_e8.2_400bps_hac@v4.1.0

#R9.4.1
# MODEL=${MODEL_DIR}/dna_r9.4.1_e8_sup@v3.6
# MODEL=${MODEL_DIR}/dna_r9.4.1_e8_hac@v3.3

###################################################################

# Make sure to change:
# 1. wv19 to your own project
# 2. the name of the model
# 3. optionally, you can select a different GPU queue instead of the default V100 queue.
#     - if you want to use the H200 GPU queue, change "gpuvolta" to "gpuhopper"
#     - if you want to use the A100 GPU queue, change "gpuvolta" to "dgxa100" and the number of CPUs to 64 (dgxa100 requires at least 16 CPUs per GPU)

# to run:
# qsub -v MERGED_SLOW5=/path/to/reads.blow5,BASECALL_OUT=/path/to/out/dir ./slow5-dorado.pbs.sh

###################################################################

usage() {
	echo "Usage: qsub -v MERGED_SLOW5=/g/data/wv19/public/hg2_prom_lsk114_subsubsample/reads.blow5,BASECALL_OUT=/scratch/wv19/hg1112/tmp/hg2_prom_lsk114_subsubsample/ ./slow5-dorado.pbs.sh" >&2
	echo
	exit 1
}

# directory where basecalls should be written to
[ -z "${BASECALL_OUT}" ] && usage
#where the merged BLOW5 file is
[ -z "${MERGED_SLOW5}" ] && usage

module load /g/data/if89/apps/modulefiles/slow5-dorado/0.9.6
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

/usr/bin/time -v slow5-dorado basecaller ${MODEL} ${MERGED_SLOW5} --emit-fastq -x cuda:all > reads.fastq

echo "basecalling success"
