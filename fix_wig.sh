if [ "$1" == "" ]; then
    echo Use: fix_wig.sh [first sequence name]
    exit
fi

firstChrom=$1

for i in genome.positive_strand.wig genome.negative_strand.wig; do
    file=$i
    base=`basename $file .wig`
    out=$base.fixed.wig
    echo Converting $file into $out
    grep -v "^$" $file | sed -e "s/chrom=chr1 /chrom=$firstChrom /" > $out
done
