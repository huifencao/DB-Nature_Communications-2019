in=$1
out=$2
samtools view -b -S $in  >$in.bam
bedtools  bamtobed -tag NM -i $in.bam >$in.bed
rm -f $in.bam

cat $in.bed | awk '$6 == "+"' | awk  '{print $1"\t"$2"\t"$2+1"\t"$4"\t"$5"\t"$6}' >$in.bed.plus
cat $in.bed | awk '$6 == "-"' | awk '{print $1"\t"$3-1"\t"$3"\t"$4"\t"$5"\t"$6}' >$in.bed.minus
cat $in.bed.plus $in.bed.minus | sort -k1,1 -k2n,2 >$out
rm -f $in.bed.plus $in.bed.minus



