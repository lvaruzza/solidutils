#!/usr/bin/env perl
#use Bio::Tools::GFF;
use Getopt::Declare;
use Data::Dumper;
use Bio::FeatureIO::gtf;
use Bio::FeatureIO::gff;
use strict;


#my $input_filename = "Sbicolor_79_gene_exons.gff3";

our $input_filename = "undef";
our $output_filename = "undef";

my $spec = q(
	-i <input:s>	Input File	
             { $::input_filename = $input; }
	-o <output:s>	Output Genome File	
             { $::output_filename = $output; }
);

my $parser = new Getopt::Declare $spec;


if ($input_filename == undef) {
    print STDERR "ERROR: Missing input filename\n";
    $parser->usage();
    exit;
}

if ($output_filename == undef) {
    print STDERR "ERROR: Missing output filename\n";
    $parser->usage();
    exit;
}

# Read the genes

print STDERR "Reading Transcripts from $input_filename\n";

my $gffio = Bio::FeatureIO::gff->new(-file => $input_filename, -gff_version => 3);

my %filter = (mRNA=>1);
my %transcripts;
my $transcript_count = 0;

while(my $feature = $gffio->next_feature()) {
    if ($filter{$feature->primary_tag} == 1) {
	#print Dumper($feature)," \n";
	my $pacid        = ($feature->get_tag_values("ID"))[0];
	my $geneid       = ($feature->get_tag_values("Parent"))[0];
	my $transcriptid = ($feature->get_tag_values("Name"))[0];

	$transcripts{$pacid} = {geneid=>$geneid,transcriptid=>$transcriptid};
	$transcript_count++;
	if ($transcript_count % 100 == 0) {
	    print STDERR ".";
	    flush STDERR;
	}
	if ($transcript_count % (50*100) == 0) {
	    print STDERR " $transcript_count\n";
	    flush STDERR;
	}

    }
}
$gffio->close();

#print Dumper(\%transcripts),"\n";

print STDERR "\nTotal transcript $transcript_count\n";

my %remove_tags = (gene=>1,mRNA=>1);

# Do the conversion
print STDERR "Doing the conversion\n";

$gffio = Bio::FeatureIO::gff->new(-file => $input_filename, -gff_version => 3);
my $gtfout = Bio::FeatureIO::gtf->new(-file => ">$output_filename");
my %remove = (mRNA=>1,gene=>1);

my $feature_count = 0;

while(my $feature = $gffio->next_feature()) {
    if ($remove{$feature->primary_tag} != 1) {	
	my $pacid = ($feature->get_tag_values("Parent"))[0];
	my $parent = $transcripts{$pacid};
	#print Dumper([$pacid,$parent]),"\n";

	$feature->add_tag_value("gene_id",$parent->{geneid});
	$feature->add_tag_value("transcript_id",$parent->{transcriptid});
	$gtfout->write_feature($feature);
	$feature_count++;
	if ($feature_count % 100 == 0) {
	    print STDERR ".";
	    flush STDERR;
	}
	if ($feature_count % (50*100) == 0) {
	    print STDERR " $transcript_count\n";
	    flush STDERR;
	}
    }
}
print STDERR "\nTotal features $feature_count\n";

$gtfout->close();
$gffio->close();
