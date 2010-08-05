#!/usr/bin/env perl

use Getopt::Std;

our($opt_n);

getopts('nc');

my $filter_mached = ($opt_n != 1);
my $clean_header = ($opt_c == 1);

my $a=0;
my $b=0;

while(<>) {
    if (/^>/) {
	chomp;	
	my @h=split(",",substr($_,1));
	my $seq=<>;
	#print "$_ ",scalar(@h),"\n";

	if (!((scalar(@h)>1) xor $filter_mached)) {
	    print ">",($clean_header ? $h[0] : join(",",@h)),"\n$seq";
	    $a++;
	} else {
	    $b++;
	}
    }
}

if ($filter_mached) {
    print STDERR "Mached:     $a\n";
    print STDERR "Non-Mached: $b\n";
} else {
    print STDERR "Mached:     $b\n";
    print STDERR "Non-Mached: $a\n";
}


