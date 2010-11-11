#!/usr/bin/perl
use strict;

# reformat single-end SOLiD FASTQ data from Short Read Archive
# to work successfully with patched version of TopHat 1.1.0

foreach my $arg(@ARGV)
{
    my ($stem)=($arg=~/(.*).fastq$/);;
    die "Could not identify stem in $arg\n" unless (defined $stem);
    
    open(IN,$arg);
    open(FASTA,">$stem.csfasta");
    open(QUAL,">$stem.qual");
    while (my $idLineA=<IN>)
    {
        chomp($idLineA);
        my ($id)=($idLineA=~/^.([^ ]+)/);
        my $seqLine=<IN>;
        my $idLineB=<IN>;
        my $qualLine=<IN>;
        chomp($qualLine);
        my @qualVals=();
        foreach my $qualChar(split(//,$qualLine))
        {
            my $qualVal=ord($qualChar)-33;
            if ($qualVal<0)
            {
                $qualVal=0;
                print STDERR ">$qualChar< for $idLineB\n";
            }
            push(@qualVals,$qualVal);
        }
        shift(@qualVals); # dump first qual val
        print FASTA ">$id\n";
        print FASTA $seqLine;
        print QUAL ">$id\n";
        print QUAL join(" ",@qualVals),"\n";
    }
}
