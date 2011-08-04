#!/usr/bin/env perl

use IO::Handle;
STDERR->autoflush(1);

my $file=$ARGV[0];
my $lines=$ARGV[1];

my $samtools="samtools";

my $header=`$samtools view -H $file`;

#print $header;

open(IN,"samtools view $file|");

my $count=0;
my $num=0;

while(<IN>) {
    if ($count % $lines == 0) {
	close OUT;
	$num++;
	my $outfile=$file . "." . sprintf("%04d",$num);
	print STDERR "Openning file $outfile\n";
	open(OUT,"|samtools view -S -b - >$outfile");
	print OUT $header;
    }
    if (($count+1) % 10000 == 0) {
	print STDERR ".";
    }
    if (($count+1) % (50*10000) == 0) {
	if ($count < 1_000_000) {
	    print STDERR sprintf("%6dk\n",($count+1)/1000);
	} else {
	    print STDERR sprintf("%6.2fM\n",($count+1)/1_000_000.0);
	}
    }

    print OUT $_;
    $count++;
}
close OUT;
