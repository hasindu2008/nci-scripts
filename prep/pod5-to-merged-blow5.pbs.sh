#!/bin/bash
#PBS -P wv19
#PBS -N P2S
#PBS -q normal
#PBS -l ncpus=32
#PBS -l mem=128GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+scratch/wv19+gdata/wv19

###################################################################

usage() {
	echo "Usage: qsub -v POD5_PATH=/g/data/wv19/public/hg2_prom_lsk114_subsubsample/pod5,TEMP_DIR=/scratch/wv19/hg1112/tmp/slow5_tmp,MERGED_SLOW5=/scratch/wv19/hg1112/tmp/hg2_prom_lsk114_merged.blow5  ./pod5-to-merged-blow5.pbs.sh" >&2
	echo
	exit 1
}

#dir containing FAST5 files
[ -z "${POD5_PATH}" ] && usage
#change this to a temporary dircetory with enough space for temp files of slow5tools
[ -z "${TEMP_DIR}" ] && usage
#change this to a where your final merged BLOW5 file should be
[ -z "${MERGED_SLOW5}" ] && usage


#change this to where you slow5tools module is
module load /g/data/if89/apps/modulefiles/slow5tools/1.3.0
module load /g/data/if89/apps/modulefiles/blue-crab/0.3.0
SLOW5TOOLS=slow5tools
BLUECRAB=blue-crab

###################################################################
###################################################################

num_threads=${PBS_NCPUS}

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

test -d ${POD5_PATH}/ || die "${POD5_PATH} does not exist."
test -d ${TEMP_DIR} && die "Temporary directory ${TEMP_DIR} already exists. Please delete it first or give an alternate location. Exiting."
test -e ${MERGED_SLOW5} &&  die "${MERGED_SLOW5} already exists. Please delete it first or give an alternate location. Exiting."

echo -n "Slow5tools version: "
$SLOW5TOOLS --version ||  die "Slow5tools not found. Exiting."

echo -n "Slow5tools version: "
$BLUECRAB --version ||  die "Blue-crab not found. Exiting."

echo "Converting"
$BLUECRAB p2s ${POD5_PATH} -d ${TEMP_DIR} -p ${PBS_NCPUS} || die "blue-crab p2s failed. Exiting."

echo "Merging"
$SLOW5TOOLS merge -t ${PBS_NCPUS} -o ${MERGED_SLOW5} ${TEMP_DIR} ||  die "slow5tools merge failed. Exiting."

echo "quickcheck"
$SLOW5TOOLS quickcheck  ${MERGED_SLOW5} ||  die "slow5tools quickcheck failed. Exiting."

echo "indexing"
$SLOW5TOOLS index ${MERGED_SLOW5} ||  die "slow5tools index failed. Exiting."

echo "removing temporary files"
rm -r ${TEMP_DIR}

echo "success converting"

