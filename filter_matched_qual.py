import Bio

from Bio import SeqIO
from optparse import OptionParser
import re
import anydbm

def main():
    parser = OptionParser()
    parser.add_option("-i", "--input", dest="input",
                      help="read INPUT fastq file", metavar="INPUT")

    parser.add_option("-o", "--output", dest="output",
                      help="write OUTPUT fasta file", metavar="OUTPUT")

    parser.add_option("-q", "--qual", dest="qual",
                      help="write OUTPUT qual file", metavar="QUAL")

    (opt, args) = parser.parse_args()
    convert(opt.input,opt.qual,opt.output)

def convert(input,qual,output):
    input_handle = open(input, "rU")
    db = anydbm.open('cache', 'c')

    sequences = SeqIO.parse(input_handle, "fasta")
    
    for seq in sequences:
        if re.search(",",seq.name):            
            name = seq.name.split(",")[0]
            db[name]="1"
    input_handle.close()

    qual_handle = open(qual, "rU")
    quals = SeqIO.parse(qual_handle, "qual")

    for qual in quals:
        if db.has_key(qual.name):
            print qual.name
            print " ".join([str(x) for x in qual.letter_annotations["phred_quality"]])
    qual_handle.close()
    db.close()

main()
