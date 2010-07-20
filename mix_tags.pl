#!/usr/bin/env perl

use BerkeleyDB;
use Fcntl; # For O_RDWR, O_CREAT, etc.
#use SDBM_File;
use Data::Dumper;
use File::Basename;
use Time::HiRes qw(gettimeofday);

use strict;

sub read_file {
    my $file = shift;
    my $hashfile = shift;
    my $base=basename($file,".fa",".fasta",".csfasta");
    open PERFLOG,">$base.perf.log";

    if (-f $hashfile) {
	print STDERR "Deleting $hashfile\n";
	unlink $hashfile ;
    }

    print STDERR "Created temporary file $hashfile\n";

    my %hash;

    tie(%hash, "BerkeleyDB::Btree",
    -Filename => $hashfile,
      -Flags    => DB_CREATE)
         or die "Cannot open file $hashfile: $! $BerkeleyDB::Error\n" ;


#    tie(%hash, 'SDBM_File', $hashfile, O_RDWR|O_CREAT, 0666)
#	or die "Couldn't tie SDBM file $hashfile: $!; aborting";
    
    print STDERR "Reading $file\n";
    my $count=1;
    my $t0 = gettimeofday();

    open F,"<$file" or die $!;
    while(my $header=<F>) {
	my $seq = <F>;
	chomp $header;
	chomp $seq;
	($header)= $header =~ /^>([0-9_]+)_[FR]./;
	$hash{$header}=$seq;
	if ($count%2_000 == 0) {
	    print STDERR ".";
	}
	if ($count%100_000 == 0) {
	    my $t1 = gettimeofday();
	    my $krps = 100.0/($t1-$t0);
	    print STDERR " ",sprintf("%9d",$count),"  ",sprintf("%.2f",$krps),"k reads/s\n";
	    print PERFLOG "$count\t$krps\n";
	    flush PERFLOG;
	    $t0 = gettimeofday();
	}
	$count++;
    }    
    print STDERR " FINISH\n";
    close F;
    close PERFLOG;

    return (\%hash,$count);
}

my $f3file = shift @ARGV or die "missing argument";
my $r3file = shift @ARGV or die "missing argument";
my $scratch = (shift @ARGV) || "/scratch/";

my $base_f3_file = basename($f3file,".csfasta");
my $f3hash_file = "$scratch/temp_${base_f3_file}_$$.db";

my $base_r3_file = basename($r3file,".csfasta");
my $r3hash_file = "$scratch/temp_${base_r3_file}_$$.db";

print STDERR "==========================================\n";

my ($f3,$f3count) = read_file($f3file,$f3hash_file);

print STDERR "==========================================\n";

my ($r3,$r3count) = read_file($r3file,$r3hash_file);

#print join(" ",keys(%$f3)),"\n";

print STDERR "Pairing\n";

open PAIRS,">mixed_mates.csfasta" or die $!;
open SINGLE,">singlets.csfasta" or die $!;

my $pairs = 0;
my $r3singlets = 0;
my $f3singlets = 0;

my $count = 1;

open PERFLOG,">pairing.perf.log";

my $t0 = gettimeofday();
while (my ($f3tag,$f3seq)=each(%{$f3})) {
    next if $f3tag eq "";
    if (!($r3->{$f3tag} eq "")) {
	my $r3seq = $r3->{$f3tag};
	print PAIRS ">"."$f3tag"."_F3\n";
	print PAIRS "$f3seq\n";
	print PAIRS ">"."$f3tag"."_R3\n";
	print PAIRS "$r3seq\n";
	$pairs++;
    } else {
	print SINGLE ">"."$f3tag"."_F3\n";
	print SINGLE "$f3seq\n";
	$f3singlets++;
    }
    print STDERR "+"  if ($count % 2000 == 0);
    if ($count % 100_000 == 0) {
	my $t1 = gettimeofday();
	my $krps = 100.0/($t1-$t0);
	print STDERR (" ",sprintf("%9d",$count)," ",sprintf("(%.2f)",$count*100.0/$f3count),"% ",
		      sprintf("%.2f",$krps),"k reads/s",
	              " (",sprintf("%.1f",($f3count-$count)/$krps),"s to finish)\n");
	print PERFLOG "$count\t$krps\n";
	flush PERFLOG;
	$t0 = gettimeofday();
    }
    $count ++;
}
print " FINISH\n";

print STDERR "Finding remaining R3 singlets\n";

$count = 1;
$t0 = gettimeofday();
while (my ($r3tag,$r3seq)=each(%{$r3})) {
    next if $r3tag eq "";
    #print STDERR $r3tag," ",$f3->{$r3tag}," ",$r3->{$r3tag},"\n";
    if ($f3->{$r3tag} eq "") {
	print SINGLE ">"."$r3tag"."_R3\n";
	print SINGLE "$r3seq\n";
	$r3singlets++;
    }
    print STDERR "-"  if ($count % 2000 == 0);
    if ($count % 100_000 == 0) {
	my $t1 = gettimeofday();
	my $krps = 100.0/($t1-$t0);
	print STDERR (" ",sprintf("%9d",$count),"  ",sprintf("(%.2f)",$count*100.0/$r3count),"% ",
		      sprintf("%.2f",$krps),"k reads/s",
	              " (",sprintf("%.1f",($r3count-$count)/$krps),"s to finish)\n");
	$t0 = gettimeofday();
    }
    $count ++;
}
print " FINISH\n";

close PAIRS;
close SINGLE;

untie %{$f3};
print STDERR "Deleting $f3hash_file\n";
unlink $f3hash_file;

untie %{$r3};
print STDERR "Deleting $r3hash_file\n";
unlink $r3hash_file;

print<<END;
Mate pairs = $pairs
F3 Singlets = $f3singlets
R3 Singlets = $r3singlets
END

