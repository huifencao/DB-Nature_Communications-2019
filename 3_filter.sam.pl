#this is for extracting the proper matched_left reads#####
#mapped in correct orientation and within insert sieze####
#flag flags   pair  sheet1  mate     proper? 
#99 1+2+32+64  1    map +   map -       y 
#147 1+4+8+128 2    map -   map +       y

#83	1+2+16+64   1   map -   map +       y
#163 1+2+32+128 2   map +   map -       y



#!/usr/bin/perl -w

use strict;
#use Smart::Comments;

my $file = shift;
open IN,$file or die "No input $file\n";
$file =~ s/\.sam//g;
while (<IN>) {
	chomp;
	if ($_ =~ /^\@SQ/) {
		print  "$_\n";
	}elsif ($_ =~ /^ST/) {
		my ($id,$flag,$chr,$s,$Mquality) = split /\t/,$_;
		if ($flag == 147 or $flag == 163) {
			if ($Mquality >20) {
				print  "$_\n";
			}
		}
	}
}
close IN;






