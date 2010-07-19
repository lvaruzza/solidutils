#!/usr/bin/env perl

use BerkeleyDB;
use Fcntl; # For O_RDWR, O_CREAT, etc.
#use SDBM_File;
use Data::Dumper;
use File::Basename;
use Time::HiRes;

sub read_file {
    my $file = shift;
    my $hashfile = shift;

    if (-f $hashfile) {
	print STDERR "Deleting $hashfile\n";
	unlink $hashfile ;
    }


    tie(%hash, "BerkeleyDB::Btree",
    -Filename => $hashfile,
      -Flags    => DB_CREATE)
         or die "Cannot open file $filename: $! $BerkeleyDB::Error\n" ;


#    tie(%hash, 'SDBM_File', $hashfile, O_RDWR|O_CREAT, 0666)
#	or die "Couldn't tie SDBM file $hashfile: $!; aborting";
    
    print STDERR "Created temporary file $hashfile\n";
    print STDERR "Reading $file\n";
    my $count=1;

    open F,"<$file" or die $!;
    while(my $header=<F>) {
	my $seq = <F>;
	chomp $header;
	chomp $seq;
	($header)= $header =~ /^>([0-9_]+)_[FR]./;
	$hash{$header}=$seq;
	if ($count%1_000 == 0) {
	    print ".";
	}
	if ($count%50_000 == 0) {
	    print " $count\n";
	}
	$count++;
    }
    print " FINISH\n";
    close F;
    return \%hash;
}

my $f3file = shift @ARGV or die "missing argument";
my $r3file = shift @ARGV or die "missing argument";
my $scratch = (shift @ARGV) || "/scratch/";

my $base_f3_file = basename($f3file,".csfasta");
my $f3hash = "$scratch/temp_${base_f3_file}_$$.db";

my $base_r3_file = basename($r3file,".csfasta");
my $r3hash = "$scratch/temp_${base_r3_file}_$$.db";

my $f3 = read_file($f3file,$f3hash);

print "==========================================\n";

my $r3 = read_file($r3file,$r3hash);

open PAIRS,">mixed_mates.csfasta" or die $!;
open SINGLE,">fragments.csfasta" or die $!;

print STDERR "Pairing\n";

while (my ($f3tag,$f3seq)=each(%{$f3})) {
    my $r3seq = $r3->{$f3tag};
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

print STDERR "Finding remaining R3 singlets\n";

while (my ($r3tag,$r3seq)=each(%{$r3})) {
    if (!defined($f3->{$r3tag})) {
	print SINGLE ">"."$r3tag"."_R3\n";
	print SINGLE "$r3seq\n";	
    }
}

close PAIRS;
close SINGLE;

untie %f3;
print STDERR "Deleting $f3hash\n";
unlink $f3hash;

untie %r3;
print STDERR "Deleting $r3hash\n";
unlink $r3hash;
