#!/usr/bin/perl -w
use strict;
#use Smart::Comments;


my $file1 = $ARGV[0];
my $file2 = $ARGV[1];
my $Flag1 = $ARGV[2]; # Tag of read1 10G "GGGGGGGGGG"  
my $Flag2 = $ARGV[3]; # Tag of read2 12T "TTTTTTTTTTTT";  

open OUT1,'>',"$file1.trim" ;
open OUT2,'>',"$file2.trim";

my %fq1 = get_fastq($file1);
my %fq2 = get_fastq($file2);
my $Cut1 = length($Flag1);                                                                                     
my $Cut2 = length($Flag2); 


for my $key (sort keys %fq1) {
	my $seq1 = $fq1{$key}{'seq'};
	if (exists $fq2{$key}) {
		my $seq2 = $fq2{$key}{'seq'};
	        if ($seq1 =~ /^$Flag1[ATC]/ and $seq2 =~ /^$Flag2[AGC]/) {  
			my $len1 = length($seq1);
			my $len2 = length($seq2);
			my $new_seq1 = substr($seq1,$Cut1,$len1-$Cut1);
			my $new_quality1    = substr($fq1{$key}{'quality'},$Cut1,$len1-$Cut1);
			my $new_seq2 = substr($seq2,$Cut2,$len2-$Cut2);
			my $new_quality2    = substr($fq2{$key}{'quality'},$Cut2,$len2-$Cut2);
			print OUT1 "$key\n$new_seq1\n$fq1{$key}{'strand'}\n$new_quality1\n";
			print OUT2 "$key\n$new_seq2\n$fq2{$key}{'strand'}\n$new_quality2\n";
		}else {next;}
	}else {next;}
}




sub get_fastq {
    my $file = shift;
    open IN,'<',$file or die "No $file \n";
    my $key = '';
    my $num = 0;
    my %index = ();
    while (<IN>) {
        chomp;
        $num += 1;
        if ($num%4 == 1) {
            ($key) = split /\s+/,$_;
        }elsif ($num%4 == 2) {
            $index{$key}{'seq'} = $_;
        }elsif ($num%4 == 3) {
            $index{$key}{'strand'} = $_;
        }elsif ($num%4 == 0) {
            $index{$key}{'quality'} = $_;
        }

    }
	close IN;
    return %index;
}





