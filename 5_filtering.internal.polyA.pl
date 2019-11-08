
#!/usr/bin/perl -w
use strict;
#use Smart::Comments;

### usage: perl 5_filtering.internal.polyA.pl Break.bed Genome.fa 20 0.4 >Break.without.polyA.bed 

my $Reads = $ARGV[0]; ## input bed file ##
my $Genome_fa = $ARGV[1]; ## input reference genome fasta ## 
my $Extract_length = $ARGV[2] || 20; ## the up/down-stream length calculated for polyA ratio ##
my $Ratio_cutoff = $ARGV[3] || 0.4; ## the criteria of internal polyA ratio ##

my %Reads_bed  = get_bed_file($Reads);
my %Genome = get_fa($Genome_fa);

### calculate the A ratio ###
my %Reads_Aratio=();
for my $chr (sort keys %Reads_bed) {	
	my $chr_seq = '';
	if (exists $Genome{$chr}) {
		$chr_seq = $Genome{$chr};
	}elsif (!exists $Genome{$chr}) {
		print "No $chr\terror\n";
		last;
	}
	my @reads = @{$Reads_bed{$chr}};
	for (my $i=0;$i<=$#reads;$i++) {
		my ($ns,$ne,$rid,$strand) = @{$reads[$i]};
		if ($ne < $ns) {my $tmp = $ns; $ns = $ne;$ne = $tmp;};
		#-----get  +/- 20 bp;-------------
		my $rid_seq_for = uc(substr($chr_seq,$ns-$Extract_length,$Extract_length));
		my $rid_seq_back = uc(substr($chr_seq,$ne+1,$Extract_length));
		$rid_seq_back = reverse($rid_seq_back);
		$rid_seq_back =~ tr/ACGTacgt/TGCAtgca/;
		my $AA_num = 0;
		if ($strand eq '+') {
			#upstream--
			$AA_num = ($rid_seq_for =~ s/T/#/g);
		}elsif ($strand eq '-') {
			#downstream--
			$AA_num = ($rid_seq_back =~ s/T/#/g);
		}
		my $aa_ratio = $AA_num/$Extract_length;	
		### $rid
		### $aa_ratio
		if ($aa_ratio < $Ratio_cutoff) {
			push @{$Reads_Aratio{$chr}},[$ns,$ne,$rid,$aa_ratio,$strand];
		}
	}#i
}

#### print the output ###
for my $chr (sort keys %Reads_Aratio) {
	my @tmp = @{$Reads_Aratio{$chr}};
	my @sort = sort {$a->[1] <=> $b->[1]} @tmp;
	my $num = @sort;
	for my $i (@sort) {
		my ($ns,$ne,$rid,$aa_ratio,$strand) = @{$i};
		print "$chr\t$ns\t$ne\t$rid\t$aa_ratio\t$strand\n";
	}
}


sub get_bed_file {
	my $file = shift;
	open IN2,'<',$file, or die "No bed input";
	my %index = ();
	while (my $line = <IN2>) {
		chomp $line;
		my ($chr,$s,$e,$rid,undef,$strand) = split /\t/,$line;
		push @{$index{$chr}},[$s,$e,$rid,$strand];
	} 
	close IN2;
	return %index;
}


sub get_fa {
	my $file = shift;
	open IN1,'<',$file, or die "No Genome Files";
	my %index = ();
	my $key = '';
	while (my $line = <IN1>) {
		chomp $line;
		if ($line =~ /^>(.*?)$/) {
			$key = $1;
			($key) = split /\s+/,$key;	
		}else {
			$line =~ s/\s+//g;
			if (!exists $index{$key}) {
				$index{$key} = $line;
			}else {
				$index{$key} .= $line;
			}
		}	
	}
	close IN1;
	return %index;
}



