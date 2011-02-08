while(<>) {
    if(/^>/) {
	print;
    } else {
	$x = $_;
	$i = 0;
	$l = length($x);

	while($i<$l) {
	    print substr($x,$i,80),"\n";
	    #print STDERR $i," ",length($x),"\n";
	    $i+=80;
	}
    }
}
