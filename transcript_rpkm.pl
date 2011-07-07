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

my %c;

my $header1 = <>;
my $header2 = <>;

my ($total) = ($header2 =~ /#number_of_mapped_reads=(\d+)/);

print "Total mapped reads = $total\n";

while(<>) {
    next if(/^#/);
    #print;

    chomp;
    
    my @l=split("\t");
    my $type = $l[2];
    my $start = $l[3];
    my $end = $l[4];
    my $len = $end-$start+1;
    my $attr = parse_attr($l[8]);
    my $count = $l[5];

    my $t_id = $attr->{transcript_id};
    my $g_id = $attr->{gene_id};
    my $gene = $attr->{gene_name};
    my $en = $attr->{exon_number};

    #print "$type $t_id $g_id $count $en\n";

    if ($type eq "exon") {
	#print "$t_id $type $len $count\n";
	$c{$t_id} += $count;
	$l{$t_id} += $len;
    }

    #print "attr = ",Dumper($attr),"\n";
    #print "==============\n";
}

my $omega = (1000.0*1000*1000)/$total;

print join("\t",qw(transcript_id count length rpkm)),"\n";

while(my ($t,$c) = each(%c)) {
    my $l = $l{$t};

    my $rpkm =  $c*1.0/$l * $omega;

    print join("\t",$t,$c,$l,$rpkm),"\n";
}
