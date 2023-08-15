#!/bin/bash
#PBS -P wv19
#PBS -N EEL
#PBS -q gpuvolta
#PBS -l ncpus=48
#PBS -l ngpus=4
#PBS -l mem=384GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+scratch/wv19+gdata/wv19

###################################################################

ONT_GUPPY_PATH=/g/data/if89/apps/buttery-eel/0.3.1/ont-guppy-6.4.2/bin
MODEL=dna_r10.4.1_e8.2_400bps_sup_prom.cfg

###################################################################

# Make sure to change:
# 1. wv19 to your own project
# 2. the name of the Guppy model

# to run:
# qsub -v MERGED_SLOW5=/path/to/reads.blow5,BASECALL_OUT=/path/to/out/dir ./buttery-eel.pbs.sh

###################################################################

usage() {
	echo "Usage: qsub -v MERGED_SLOW5=/g/data/wv19/public/hg2_prom_lsk114_subsubsample/reads.blow5,BASECALL_OUT=/scratch/wv19/hg1112/tmp/hg2_prom_lsk114_subsubsample/ ./buttery-eel.pbs.sh" >&2
	echo
	exit 1
}

#directory where basecalls should be written to
[ -z "${BASECALL_OUT}" ] && usage
# merged BLOW5
[ -z "${MERGED_SLOW5}" ] && usage

module load /g/data/if89/apps/modulefiles/buttery-eel/0.3.1

###################################################################

PORT=5000

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

test -d ${BASECALL_OUT} && die "Output directory ${BASECALL_OUT} already exists. Please delete it first or give an alternate location. Exiting."

test -e ${MERGED_SLOW5} || die "${MERGED_SLOW5} not found. Exiting."

mkdir ${BASECALL_OUT} || die "Creating directory ${BASECALL_OUT} failed. Exiting."
cd ${BASECALL_OUT} || die "${MERGED_SLOW5} not found. Exiting."

/usr/bin/time -v  buttery-eel -i ${MERGED_SLOW5} -o ${BASECALL_OUT}/reads.fastq --guppy_bin ${ONT_GUPPY_PATH} --port ${PORT} --config ${MODEL} -x cuda:all --guppy_batchsize 20000 --max_queued_reads 20000 --slow5_threads 10 --slow5_batchsize 100 --procs 20 || die "basecalling failed"

echo "basecalling success"
