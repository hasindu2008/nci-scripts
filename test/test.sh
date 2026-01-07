#test commands

# slow5-dorado
qsub -v MERGED_SLOW5=/g/data/wv19/public/hg2_prom_lsk114_subsubsample/reads.blow5,BASECALL_OUT=/scratch/ox63/hg1112/test/hg2_prom_lsk114_subsubsample_dorado/ ./slow5-dorado.pbs.sh

qsub -v MERGED_SLOW5=/g/data/wv19/public/hg2_prom_lsk114_subsubsample/reads.blow5,BASECALL_OUT=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_guppy/ ./buttery-eel-guppy.pbs.sh
qsub -v REF=/g/data/ox63/genome/hg38noAlt.idx,FASTQ=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_guppy/reads.fastq,OUT_DIR=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_aligned ./minimap2_samtools.pbs.sh
qsub -v FASTQ=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_guppy/reads.fastq,BLOW5=/g/data/wv19/public/hg2_prom_lsk114_subsubsample/reads.blow5 ./f5c-index.pbs.sh
qsub -v REF=/g/data/ox63/genome/hg38noAlt.fa,FASTQ=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_guppy/reads.fastq,BAM=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_aligned/reads.bam,BLOW5=/g/data/wv19/public/hg2_prom_lsk114_subsubsample/reads.blow5,OUT_DIR=/scratch/wv19/hg1112/test/hg2_prom_lsk114_subsubsample_f5c ./f5c-call-methylation.pbs.sh
