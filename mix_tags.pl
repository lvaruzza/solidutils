#!/usr/bin/env perl

use BerkeleyDB;
use Data::Dumper;

sub read_file {
    my $file = shift;
    my $hashfile = shift;

    unlink $hashfile ;
    
    tie %hash, "BerkeleyDB::Hash",
      -Filename => $f3hash,
      -Flags    => DB_CREATE
         or die "Cannot open file $filename: $! $BerkeleyDB::Error\n" ;
    
    open F,"<$file" or die $!;
    while(my $header=<F>) {
	my $seq = <F>;
	chomp $header;
	chomp $seq;
	($header)= $header =~ /^>([0-9_]+)_[FR]./;
	$hash{$header}=$seq;
    }
    close F;
    return %hash;
}


my $f3file = shift @ARGV or die "missing argument";
my $f3hash = "temp_$f3file$$.db";
my $r3file = shift @ARGV or die "missing argument";
my $r3hash = "temp_$r3file$$.db";

my %f3 = read_file($f3file,$f3hash);

my %r3 = read_file($r3file,$r3hash);

open PAIRS,">mixed_mates.csfasta" or die $!;
open SINGLE,">fragments.csfasta" or die $!;

while (my ($f3tag,$f3seq)=each(%f3)) {
    my $r3seq = $r3{$f3tag};
    if (defined($r3seq)) {
	print PAIRS ">"."$f3tag"."_F3\n";
	print PAIRS "$f3seq\n";
	print PAIRS ">"."$f3tag"."_R3\n";
	print PAIRS "$r3seq\n";
    } else {
	print SINGLE ">"."$f3tag"."_F3\n";
	print SINGLE "$f3seq\n";
    }
}

while (my ($r3tag,$r3seq)=each(%r3)) {
    if (!defined($f3{$r3tag})) {
	print SINGLE ">"."$r3tag"."_R3\n";
	print SINGLE "$r3seq\n";	
    }
}

close PAIRS;
close SINGLE;

untie %f3;
unlink $f3hash;

untie %r3;
unlink $r3hash;
