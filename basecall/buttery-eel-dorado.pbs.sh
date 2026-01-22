#!/bin/bash
#PBS -P ox63
#PBS -N EEL
#PBS -q gpuvolta
#PBS -l ncpus=48
#PBS -l ngpus=4
#PBS -l mem=384GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+gdata/ox63+scratch/ox63

###################################################################

# buttery-eel0.8.1 with ont-dorado-server 7.11.2.
#
# Note: ont-dorado-server 7.11.2 and above only supports R10.4.1 5KHz data and newer.
#
# if you want to use basecalling models for older data (DNA R10.4.1 4kHz, DNA R9.4.1, and RNA002)
# please use an older script under archived/ instead.

# Change this to the model you want to use
MODEL=dna_r10.4.1_e8.2_400bps_sup@v5.2.0

###################################################################

# Make sure to change:
# 1. ox63 to your own project
# 2. the name of the model
# 3. optionally, you can select a different GPU queue instead of the default V100 queue.
#     - if you want to use the H200 GPU queue, change "gpuvolta" to "gpuhopper"
#     - if you want to use the A100 GPU queue, change "gpuvolta" to "dgxa100" and the number of CPUs to 64 (dgxa100 requires at least 16 CPUs per GPU)

# to run:
# qsub -v MERGED_SLOW5=/path/to/reads.blow5,BASECALL_OUT=/path/to/out/dir ./buttery-eel-dorado.pbs.sh

###################################################################

usage() {
	echo "Usage: qsub -v MERGED_SLOW5=/g/data/ox63/slow5-testdata/hg2_prom_lsk114_5khz_subsubsample/PGXXXX230339_reads_20k.blow5,BASECALL_OUT=/scratch/ox63/hg1112/tmp/hg2_prom_lsk114_5khz_subsubsample/ ./buttery-eel-dorado.pbs.sh" >&2
	echo
	exit 1
}

#directory where basecalls should be written to
[ -z "${BASECALL_OUT}" ] && usage
# merged BLOW5
[ -z "${MERGED_SLOW5}" ] && usage

module load /g/data/if89/apps/modulefiles/buttery-eel/0.8.1+dorado7.11.2

###################################################################

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

#https://unix.stackexchange.com/questions/55913/whats-the-easiest-way-to-find-an-unused-local-port
PORT=5000
get_free_port() {
	for port in $(seq 5000 65000); do
		echo "trying port $port" >&2
		PORT=$port
		ss -lpna | grep -q ":$port " || break
	done
}

get_free_port
test -z "${PORT}" && die "Could not find a free port"
echo "Using port ${PORT}"

ONT_DORADO_PATH=$(which dorado_basecall_server | sed "s/dorado\_basecall\_server$//")/
${ONT_DORADO_PATH}/dorado_basecall_server --version || die "Could not find dorado_basecall_server"

test -d ${BASECALL_OUT} && die "Output directory ${BASECALL_OUT} already exists. Please delete it first or give an alternate location. Exiting."

test -e ${MERGED_SLOW5} || die "${MERGED_SLOW5} not found. Exiting."

mkdir ${BASECALL_OUT} || die "Creating directory ${BASECALL_OUT} failed. Exiting."
cd ${BASECALL_OUT} || die "${BASECALL_OUT} not found. Exiting."

/usr/bin/time -v  buttery-eel -i ${MERGED_SLOW5} -o ${BASECALL_OUT}/reads.fastq -g ${ONT_DORADO_PATH} --port ${PORT} --use_tcp --config ${MODEL} -x cuda:all --slow5_threads 10 --slow5_batchsize 4000 --procs 20 || die "basecalling failed"

echo "basecalling success"
