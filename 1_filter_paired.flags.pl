#!/usr/bin/perl -w
use strict;
#use Smart::Comments;

my $file1 = $ARGV[0];
my $file2 = $ARGV[1];
open OUT1,'>',"$file1.trim";
open OUT2,'>',"$file2.trim";

my %fq1 = get_fastq($file1);
my %fq2 = get_fastq($file2);

#my $flag1 = "GGGGGGGGGG"; #10Gs
#my $flag2 = "TTTTTTTTTTTT"; #12Ts

for my $key (sort keys %fq1) {
	my $seq1 = $fq1{$key}{'seq'};
	if (exists $fq2{$key}) {
		my $seq2 = $fq2{$key}{'seq'};
		if ($seq1 =~ /^GGGGGGGGGG/ and $seq2 =~ /^TTTTTTTTTTTT/) {
			my $len1 = length($seq1);
			my $len2 = length($seq2);
			my $new_seq1 = substr($seq1,11,$len1-10);
			my $new_quality1    = substr($fq1{$key}{'quality'},11,$len1-10);
			my $new_seq2 = substr($seq2,13,$len2-12);
			my $new_quality2    = substr($fq2{$key}{'quality'},13,$len2-12);
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





