#!/bin/bash
#PBS -P ox63
#PBS -N SLOW5-DORADO
#PBS -q gpuvolta
#PBS -l ncpus=12
#PBS -l ngpus=1
#PBS -l mem=96GB
#PBS -l walltime=2:00:00
#PBS -l wd
#PBS -l storage=gdata/if89+scratch/wv19+gdata/wv19+gdata/ox63

###################################################################

#R10.4.1 5KHz
MODEL=/g/data/if89/apps/slow5-dorado/0.3.4/slow5-dorado/models/dna_r10.4.1_e8.2_400bps_sup@v4.2.0
# MODEL=/g/data/if89/apps/slow5-dorado/0.3.4/slow5-dorado/models/dna_r10.4.1_e8.2_400bps_hac@v4.2.0

#R10.4.1 4KHz
MODEL=/g/data/if89/apps/slow5-dorado/0.3.4/slow5-dorado/models/dna_r10.4.1_e8.2_400bps_sup@v4.1.0
# MODEL=/g/data/if89/apps/slow5-dorado/0.3.4/slow5-dorado/models/dna_r10.4.1_e8.2_400bps_hac@v4.1.0

#R9.4.1
# MODEL=/g/data/if89/apps/slow5-dorado/0.3.4/slow5-dorado/models/dna_r9.4.1_e8_sup@v3.6
# MODEL=/g/data/if89/apps/slow5-dorado/0.3.4/slow5-dorado/models/dna_r9.4.1_e8_hac@v3.3

###################################################################

# Make sure to change:
# 1. wv19 to your own project
# 2. the name of the Model

# to run:
# qsub -v MERGED_SLOW5=/path/to/reads.blow5,BASECALL_OUT=/path/to/out/dir ./slow5-dorado.pbs.sh

###################################################################

usage() {
	echo "Usage: qsub -v SLOW5=/g/data/wv19/public/hg2_prom_lsk114_subsubsample/reads.blow5,BASECALL_OUT=/scratch/wv19/hg1112/tmp/hg2_prom_lsk114_subsubsample/ ./slow5-dorado-duplex.pbs.sh" >&2
	echo
	exit 1
}

# directory where basecalls should be written to
[ -z "${BASECALL_OUT}" ] && usage
#where the merged BLOW5 file is
[ -z "${SLOW5}" ] && usage

module load /g/data/if89/apps/modulefiles/slow5-dorado/0.3.4
num_threads=${PBS_NCPUS}

# terminate script
die() {
	echo "$1" >&2
	echo
	exit 1
}

test -d ${BASECALL_OUT} || mkdir ${BASECALL_OUT}

test -e ${SLOW5} || die "${SLOW5} not found. Exiting."

NAME=$(basename ${SLOW5})
NAME=${NAME%.blow5}

test -e ${BASECALL_OUT}/${NAME}.bam && die "${BASECALL_OUT}/${NAME}.bam already exists. Exiting."
/usr/bin/time -v  slow5-dorado duplex ${MODEL} ${SLOW5}  -x cuda:all > ${BASECALL_OUT}/${NAME}.bam

echo "basecalling ${SLOW5} success"
