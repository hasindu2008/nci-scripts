#!/bin/bash
#PBS -P ox63
#PBS -N slow5
#PBS -q normal
#PBS -l ncpus=32
#PBS -l mem=128GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+scratch/ox63+gdata/ox63+gdata/wv19+scratch/wv19

###################################################################

usage() {
	echo "Usage: qsub -v SLOW5_PATH=/g/data/wv19/public/hg2_prom_lsk114_subsubsample/reads.blow5,REDUCED_SLOW5=/scratch/wv19/hg1112/tmp/hg2_prom_lsk114_reduced.blow5  ./reduce-blow5.pbs.sh" >&2
	echo
	exit 1
}

#original SLOW5
[ -z "${SLOW5_PATH}" ] && usage
#change this to a where your final reduced (lossy compressed) SLOW5 file should be
[ -z "${REDUCED_SLOW5}" ] && usage


#change this to where you slow5tools module is
module load /g/data/if89/apps/modulefiles/slow5tools/1.3.0
SLOW5TOOLS=slow5tools

###################################################################
###################################################################

num_threads=${PBS_NCPUS}

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

test -e ${SLOW5_PATH} || die "${SLOW5_PATH} does not exist."
test -e ${REDUCED_SLOW5} &&  die "${REDUCED_SLOW5} already exists. Please delete it first or give an alternate location. Exiting."

echo -n "Slow5tools version: "
$SLOW5TOOLS --version ||  die "Slow5tools not found. Exiting."

echo "reduce"
$SLOW5TOOLS degrade -t ${num_threads} -o ${REDUCED_SLOW5} ${SLOW5_PATH} || die "slow5tools reduce failed. Exiting."

echo "quickcheck"
$SLOW5TOOLS quickcheck  ${REDUCED_SLOW5} ||  die "slow5tools quickcheck failed. Exiting."

echo "indexing"
$SLOW5TOOLS index ${REDUCED_SLOW5} ||  die "slow5tools index failed. Exiting."

echo "success reducing (lossy compression)"

