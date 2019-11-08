in=$1

:<<BLOCK
#step 1. extract the proper reads started with 10Gs and 12Ts and trim them;
perl 1_filter_paired.flags.pl $in\_1.clean.fq $in\_2.clean.fq  2>log.1

echo "Step one done";
#step 2. run mapping filtered reads, here is an example of Human;
###build the library of BWA first to construct BWA.ref.
bwa mem -t 8 -M -R '@RG\tID:foo\tSM:bar\tLB:library1' BWA.ref/HG19  $in\_1.clean.fq.trim $in\_2.clean.fq.trim > $in.sam

echo "Finish mapping";

#rm -f *.clean.fq.out
#step 3. extract only unique and proper mapped paired reads and extract reads2;
perl 3_filter.sam.pl  $in.sam  >$in.proper.sam 2>log.3
echo "Finish filtering sam";

#step 4. convert sam to bed file and extract the positions of SSB candidates; 
# input $in.proper.sam 
# output $in.candidates.bed  
sh 4_sam2bed.right.proper.sh $in.proper.sam $in.candidates.bed 2>log.4
echo "Finish converting bed";

BLOCK
#step 5. filtering breaks located near the genome internal high polyA regions;
perl 5_filtering.internal.polyA.pl $in.candidates.bed Human19.fasta 20 0.4 >$in.breaks.bed 3>log.5
echo "Extract the break positions";


#rm -f $in.sam $in.candidates.bed $in\_1.clean.fq.trim $in\_2.clean.fq.trim




