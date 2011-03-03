#!/usr/bin/env perl

my $st=1;

while(<>) {
    if(/^>/) {
	if (!/,/) {
	    $st = 1;
	    print;
	} else {
	    $st = 0;
	}
    } else {
	if ($st==1) {
	    print 
	}
    }
}
