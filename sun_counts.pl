use Data::Dumper;

sub parse_attr {
 my $s=shift;

 my @l=split(";",$s);
 my %r = ();
 foreach my $x (@l) {
     chomp $x;
     $x =~  /(\S+)\s+"?([^"]+)"?/;
     $r{$1}=$2;
 }

 return \%r;
}

my %h;

while(<>) {
    next if(/^#/);
    #print;

    chomp;
    
    my @l=split("\t");
    my $type = $l[2];
    my $len = $l[4]-$l[3];
    my $attr = parse_attr($l[8]);
    my $count = $l[5];

    my $t_id = $attr->{transcript_id};
    my $g_id = $attr->{gene_id};
    my $en = $attr->{exon_number};

    #print "$type $t_id $g_id $count $en\n";

    if (!($type eq "exon")) {
	$sum += $count;
    }

    #print "attr = ",Dumper($attr),"\n";
    #print "==============\n";
}
