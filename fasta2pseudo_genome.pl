use Bio::SeqIO;
use Getopt::Declare;
use strict;

our ($input,$genome,$gtf);

our $N_seps = 50;
our $genome_name = "genome";
our $source="pseudo-genome";
our $feature="CDS";
our $line_len = 60;

my $spec = q(
	-i <input:s>	Input File	
             { $::input = $input; }
	-o <genome:s>	Output Genome File	
             { $::genome = $genome; }
	-g <gtf:s>	Output GTF file
             { $::gtf = $gtf; }
	-n <name:s>	Genome Name
             { $::genome_name = $name; }
);

my $parser = new Getopt::Declare $spec;


my $seqio = new Bio::SeqIO(-format => 'fasta',-file => $input);

my $pos=1;
open(GTF,">$gtf") or die $!;
open(GENOME,">$genome") or die $!;
print GENOME ">$genome_name\n";
my $last_line = "";
print GTF "##gff-version 3\n";

while (my $seq = $seqio->next_seq) {
    my $x = $last_line . $seq->seq . ("N" x $N_seps);
    my $name = $seq->id;
    my @x = unpack("(A$line_len)*",$x);
    $last_line = pop @x;
    #print "last_line = $last_line\n";

    foreach my $line (@x) {
	print  GENOME $line,"\n";
    }
    if (length($last_line) == $line_len) {
	print GENOME $last_line,"\n";
	$last_line="";
    }
    #print "last_line = $last_line\n";

    my $endpos = $pos + length($seq->seq) + $N_seps;

    print GTF join("\t",
	       $genome_name,
	       $source,
	       "CDS",
	       $pos,
	       $endpos-1,
	       ".",
	       "+",
	       "0",
	       join("; ","gene_id \"$name\"","transcript_id \"$name\"") . ";"
	),"\n";
    $pos = $endpos;
}
print GENOME $last_line,"\n";

print "total size = ",$pos,"\n";

close GTF;
close GENOME;
