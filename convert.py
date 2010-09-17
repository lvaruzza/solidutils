#!/usr/bin/env python

from Bio import SeqIO
from optparse import OptionParser
import pprint
import sys

def main():
    parser = OptionParser()
    parser.add_option("-i", "--input", dest="input",
                      help="read INPUT fastq file", metavar="INPUT")

    parser.add_option("-o", "--output", dest="output",
                      help="write OUTPUT fasta file", metavar="OUTPUT")

    parser.add_option("-q", "--qual", dest="qual",
                      help="write OUTPUT qual file", metavar="QUAL")

    (opt, args) = parser.parse_args()

    if opt.input == None:
        print "Missing input file"
        return

    if opt.output == None:
        print "Missing output file"
        return

    print "Converting files..."

    print "Creating csfasta file"
    count = SeqIO.convert(opt.input, "fastq", opt.output, "fasta")

    print "Converted %i records" % count

    if opt.qual != None:
        print "Creating Qual file"
        count = SeqIO.convert(opt.input, "fastq", opt.qual, "qual")
        
        print "Converted %i qual records" % count
        

main()
