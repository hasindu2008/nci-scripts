#!/bin/bash
#PBS -P ox63
#PBS -N slow5tools
#PBS -q normal
#PBS -l ncpus=32
#PBS -l mem=128GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+scratch/wv19+gdata/wv19+gdata/ox63

###################################################################

usage() {
	echo "Usage: qsub -v MERGED_SLOW5=/g/data/wv19/public/hg2_prom_lsk114_subsubsample/reads.blow5,OUT_DIR=/scratch/wv19/hg1112/tmp/hg2_prom_lsk114_merged_split/  ./blow5-dechannel.pbs.sh" >&2
	echo
	exit 1
}

#change this to a dircetory with enough space for output BLOW5
[ -z "${OUT_DIR}" ] && usage
#change this to a where your input BLOW5 file is
[ -z "${MERGED_SLOW5}" ] && usage


#change this to where you slow5tools module is
#module load /g/data/if89/apps/modulefiles/slow5tools/1.1.0
SLOW5TOOLS=/home/561/hg1112/install/slow5tools/slow5tools

###################################################################
###################################################################

num_threads=${PBS_NCPUS}

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

test -e ${MERGED_SLOW5} ||  die "${MERGED_SLOW5} not found. Exiting."
test -d ${OUT_DIR} && die "Output directory ${TEMP_DIR} already exists. Please delete it first or give an alternate location. Exiting."

mkdir -p ${OUT_DIR} ||  die "Creating directory ${OUT_DIR} failed. Exiting."

echo -n "Slow5tools version: "
$SLOW5TOOLS --version ||  die "Slow5tools not found. Exiting."

echo "Skimming"
$SLOW5TOOLS skim -t ${PBS_NCPUS} ${MERGED_SLOW5} > ${OUT_DIR}/skim.txt  ||  die "slow5tools merge. Exiting."

echo "splitting"
$SLOW5TOOLS split -x ${OUT_DIR}/skim.txt ${MERGED_SLOW5} -d ${OUT_DIR}/split_by_channel/ -t ${PBS_NCPUS} --demux-rid-hdr "#read_id" --demux-code-hdr channel_number

echo "success splitting"

