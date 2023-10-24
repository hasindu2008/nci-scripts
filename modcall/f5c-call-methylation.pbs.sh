#!/bin/bash
#PBS -N F5C-METHCALL
#PBS -P wv19
#PBS -q gpuvolta
#PBS -l ncpus=12
#PBS -l ngpus=1
#PBS -l mem=96GB
#PBS -l jobfs=350GB
#PBS -l walltime=48:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+scratch/wv19+gdata/wv19+gdata/ox63

###################################################################

# Make sure to change:
# 1. wv19 and ox63 to your own projects

# to run:
# qsub -v REF=/g/data/ox63/genome/hg38noAlt.fa,FASTQ=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_guppy/reads.fastq,BAM=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_aligned/reads.bam,BLOW5=/g/data/wv19/public/hg2_prom_lsk114_subsubsample/reads.blow5,OUT_DIR=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_f5c ./f5c-call-methylation.pbs.sh

## 12 CPU cores have been requested using -l ncpus=12
## 1 GPU has been requested using -l ngpus=1
## 96 GB of RAM has been requested using -l mem=96GB
## 350 GB of local scratch storage space (fast SSD storage on the node) has been requested using -l jobfs=350GB
## note that mem=96GB and jobfs=350GB values are the totals (i.e. NOT per single core)
## it is assumed that the compute node has adequate local scratch storage space and is accessible via $PBS_JOBFS
## the local scratch space should be adequate to hold the reference genome, FASTQ file and the f5c index files (~0.6 of FASTQ size)


###################################################################

usage() {
	echo "Usage: qsub -v REF=/g/data/ox63/genome/hg38noAlt.fa,FASTQ=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_guppy/reads.fastq,BAM=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_aligned/reads.bam,BLOW5=/g/data/wv19/public/hg2_prom_lsk114_subsubsample/reads.blow5,OUT_DIR=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_f5c ./f5c-call-methylation.pbs.sh"
	echo
	exit 1
}

# FASTQ
[ -z "${REF}" ] && usage
# FASTQ
[ -z "${FASTQ}" ] && usage
# BAM
[ -z "${BAM}" ] && usage
# BLOW5
[ -z "${BLOW5}" ] && usage

module load /g/data/if89/apps/modulefiles/f5c/1.3
num_threads=${PBS_NCPUS}

###################################################################

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

test -d ${OUT_DIR} && die "Output directory ${OUT_DIR} already exists. Please delete it first or give an alternate location. Exiting."

test -e ${REF} || die "${REF} not found. Exiting."
test -e ${FASTQ} || die "${FASTQ} not found. Exiting."
test -e ${FASTQ}".index" || die "${FASTQ}.index not found. Have you run f5c index (script under prep/). Exiting."
test -e ${FASTQ}".index.fai" || die "${FASTQ}.index.fai not found. Have you run f5c index (script under prep/). Exiting."
test -e ${FASTQ}".index.gzi" || die "${FASTQ}.index.gzi not found. Have you run f5c index (script under prep/). Exiting."
test -e ${BLOW5} || die "${BLOW5} not found. Exiting."
test -e ${BAM} || die "${BAM} not found. Exiting."

mkdir ${OUT_DIR} || die "Creating directory ${OUT_DIR} failed. Exiting."

#temporary location of the reference and the FASTQ file on local scratch storage where they are to be copied
REF_LOCAL=$PBS_JOBFS/ref.fa
FASTQ_LOCAL=$PBS_JOBFS/reads.fastq

#output file
METH=$OUT_DIR/meth.tsv

#copy the reference and the FASTQ file to the local scratch storage
echo "Copying reference $REF to $REF_LOCAL"
cp $REF $REF_LOCAL || die "Copying $REF to $REF_LOCAL failed"
echo "linking $FASTQ to $FASTQ_LOCAL"
ln -s $FASTQ $FASTQ_LOCAL || die "linking $FASTQ to $FASTQ_LOCAL failed"
echo "Copying ${FASTQ}.index to ${FASTQ_LOCAL}.index"
cp ${FASTQ}".index"  ${FASTQ_LOCAL}".index" || die "Copying${FASTQ}.index to ${FASTQ_LOCAL}.index failed"
echo "Copying ${FASTQ}.index.fai to ${FASTQ_LOCAL}.index.fai"
cp ${FASTQ}".index.fai"  ${FASTQ_LOCAL}".index.fai" || die "Copying${FASTQ}.index.fai to ${FASTQ_LOCAL}.index.fai failed"
echo "Copying ${FASTQ}.index.gzi to ${FASTQ_LOCAL}.index.gzi"
cp ${FASTQ}".index.gzi"  ${FASTQ_LOCAL}".index.gzi" || die "Copying${FASTQ}.index.gzi to ${FASTQ_LOCAL}.index.gzi failed"

#methylation calling
echo "Methylation calling"
/usr/bin/time -v f5c call-methylation -x nci-gadi -t 24 -r $FASTQ_LOCAL -g $REF_LOCAL -b $BAM -K 2048 -B 20M --slow5 ${BLOW5} -o $METH || die "f5c methylation calling failed"

echo "all done"
