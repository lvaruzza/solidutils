#!/usr/bin/env perl

use Bio::DB::Sam;
use Data::Dumper;

my $sam = Bio::DB::Sam->new(-fasta =>"ecoli.fasta",-bam  =>"ex3.bam");

my $it = $sam->features(-iterator=>1);

while (my $a = $it->next_seq()) {
    print $a->dna,"\n";
    print $a->query->dna,"\n";
    print $a->cigar_str,"\n";
    print $a->get_tag_values("CS"),"\n";
    print "NM=",$a->get_tag_values("NM"),"\n";
    print "CM=",$a->get_tag_values("CM"),"\n";
    print "MD=",$a->get_tag_values("MD"),"\n";
    print join(", ",$a->get_all_tags()),"\n";
    my ($ref,$matches,$query) = $a->padded_alignment;
    print "\n";
    print $ref,"\n";
    print $matches,"\n";
    print $query,"\n";
    print "\n";
    print "=" x 30,"\n";

}
