use Bio::SeqIO;

$seqio = new Bio::SeqIO(-format => 'fasta',
                        -file   => $ARGV[0]);


while( $seq = $seqio->next_seq() ) {
    my $name = $seq->primary_id;

    $seq_out = Bio::SeqIO->new( -format => 'fasta',
				-file => ">$name.fasta");
    $seq_out->write_seq($seq);
    $seq_out->close;
}

