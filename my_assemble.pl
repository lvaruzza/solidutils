#!/usr/bin/env perl
use POSIX;

my $exeDeNovo = $ENV{"denovo2"};
my $exeSAET   = "${exeDeNovo}/saet.2.2";
my $exeVELVET = "${exeDeNovo}/velvet_0.7.55";
my $exeASiD   = "${exeDeNovo}/asid.1.0";
my $exeUTILS  = "${exeDeNovo}/utils";

open LOG,">log.txt" or die $!;

sub log_system {
    my $cmd = shift;
    print LOG $cmd,"\n";
    return system($cmd);
}


print "
De Novo Assembly Pipeline for SOLiD v.2.0
Copyright (2010) by Life Technologies 
***************************************************\n";

if ($#ARGV < 1) {
print "
Usage:

 - for fragment library data run:

  \$denovo2/assemble.pl <f3_csfasta> <f3_qual> <refLength> [-options]

 - for mate-paired library data run:
 
  \$denovo2/assemble.pl <f3_csfasta> <f3_qual> <refLength> -r3 r3_csfasta -r3qv r3_qual
                     -ins_length xx -ins_length_sd zz  [-options]

 - for paired-end library data run:
 
  \$denovo2/assemble.pl <f3_csfasta> <f3_qual> <refLength> -f5 f5_csfasta -f5qv f5_qual
                     -ins_length xx -ins_length_sd zz  [-options]

* Input: *

 
 f3_csfasta - csfasta file with 2-base encoded reads (in color space).
              in case of mate-paired data this is the file with F3 reads.
              Example: f3_csfasta
              =======================
              >469_29_17_F3
              T20330310301231330323231131013321122333132121310320
              >469_29_1434_F3
              T132113.21231311212222311021.1221112112220..2123221
              =======================
              for fragment data the title of each read is irrelevant.
              missing colors are encoded as dots.
              header of the file may contain comments and descriptions.

 f3_qual    - filename with quality values (if available). notice, that order
              of reads in csfasta file should be the same as in quality value file.
              if file is not available then input \"none\".
 refLength  - expected length of sequenced DNA region, e.g., 4600000 for E.Coli 4.6Mb genome.


* Options required for paired-end and mate-paired data: *

 -f5|-r3 r3_csfasta   csfasta file with 2-base encoded F5/R3 reads.
 -f5qv|-r3qv r3_qual  file with quality values for F5/R3 reads (if available). notice, 
                      that order of reads in csfasta file should be the same as in quality 
                      values file. Do not include this option if quality file is not available 
                      or if f3_qual is \"none\".
 -ins_length xx       estimate of insert length, e.g., xx=1200 for mate-paired library data
                      with insert length 1.2Kb.
 -ins_length_sd zz    estimate of variance of the insert length, e.g., zz=300 for mate-paired
                      library data with insert length 1.2Kb.


* Assembly Output: *

assembly/nt_contigs.fa     - fasta file with assembled base-space contigs (for fragment data)
                             or scaffolds (for mate-paired data).
assembly/merged_contigs.de - fasta file with merged contigs in double encoding space (de).
                             de is an equivalent to color space were 0=A,1=C,2=G,3=T.
                             this file is generated only for mate-paired data and is obtained
                             as an additional merging of contigs inside the scaffolds. N50 contig
                             in this file is usually by 20% longer than non-merged contigs.
assembly/velvet/contigs.fa - fasta file with assembled double encoded contigs (for fragment data)
                             or scaffolds (for mate-paired data).


* Analysis Output: *

 assembly/analysis/base_contigs/    - directory containing base-space contigs/scaffolds analysis.
 assembly/analysis/scaffolds/       - directory containing double encoded scaffolds analysis.
 assembly/analysis/contigs/         - directory containing double encoded contigs analysis.
 assembly/analysis/merge_scaffolds/ - directory containing de merged scaffolds analysis.
 assembly/analysis/merge_contigs/   - directory containing de merged contigs analysis.

- each directory contains:

 n50.stats.txt      - file reporting contigs length statistics.
 cumulative.len.txt - a list of contig sizes sorted in decreasing order, and their accumulation.
 coverage.stats.txt - percentage of genome coverage. for base-space contigs max coverage is 100%.
                      for (de) contigs maximum coverage is 50%, due to reference representation.
                      this file is generated only if reference sequence is provided.
 mapview.pdf        - a plot showing alignment between contigs and reference sequence. the file
                      is generated only if reference sequence is provided.



* OPTIONS: *

 -outdir dir        outputs results and intermediate files into \"dir\" directory
                    (default \"assembly\").
 -maxcov c          indicates the coverage formed by sub-sampled reads (default c=300).
                    if \"c\" is higher than existing coverage then whole dataset is
                    considered and value of \"c\" is changed to reflect actual coverage.
 -numcores p        number of processes used in error correction. this option is designed
                    to speed-up computation by multiprocessing.
 -read_length r     use this option to indicate read length when \"-NO_SAMPLING\" option is used.
 -ref_file rf       this option is used in analysis of results when assembled contigs are
                    compared to reference sequence. \"rf\" is a fasta file with reference
                    sequence.
 -ref_type t        indicates representation of the reference. \"t\" can be \"nt\",\"de\",\"color\",
                    or \"de2\". \"nt\" - base-space, \"de\" - double encoded, \"color\" - color
                    space, \"de2\" - double encoded forward plus reverse.


* to overwrite automatic error correction options use: *

 -trustprefix len   use only first len positions of reads to build spectrum
                    (default len = 0.8*readLength).
 -trustfreq  freq   Use this option to overwrite estimated frequency cutoff of trusted seeds.   
                    All seeds with frequency < \"freq\" are filtered out of spectrum.
 -suppvotes vn      require at least vn separate votes to fix any position. a vote is cast for
                    a position pos, nucleotide nuc, if a change at (pos,nuc) makes a seed t to
                    belong to spectrum (default vn = 2, increase if overcorrection is observed).
                    reduce if over- and increase if under- corrections are observed.
 -localrounds lr    corrects up to lr errors in a read (default lr = round(readLength/8)).
                    reduce if over- and increase if under- corrections are observed.
 -globalrounds gr   repeat recursively gr times error correction procedure (Default 2).
                    reduce if over- and increase if under- corrections are observed.


* to overwrite automatic assembly engine options use: *

 -hsize t           size of seed used in hash table (default is optimal).
 -exp_cov c         expected coverage formed by data (default is precomputed).
 -cov_cutoff ct     minimum coverage required to form a contig (default is precomputed).
 -min_pair_count z  number of mate-pair confirmations required for confident scaffolding.


* control options *

 -NO_CORRECTION     skips error correction of the data.
 -NO_BASE_SPACE     skips conversion of contigs into base-space.
 -NO_SAMPLING       skips data sub-sampling and estimation of coverage. if this option is used
                    the -maxcov and -read_length must be included to provide accurate estimation
                    of the coverage and actual read length.
 -ASSEMBLE_ONLY     use this option to rerun assembly with new options. this feature is
                    designed to tune (play with) assembly parameters without repeating
                    sampling, error correction, (de) encoding, and mates ordering.
                    if this option is included the -maxcov and -read_length options
                    are required. if all assembly parameters are overwritten, then accuracy
                    of -maxcov and read_length does not matter.
 -NO_CNT_MERGE      skips additional merging of contigs.
 -NO_ANALYSIS       skips running analysis pipeline.
 
 
 Examples of running:

 \$denovo2/assemble.pl reads.csfasta reads.qual 100000 -outdir asmb1 -maxcov 500 -numcores 5
  -ref_file reference.fasta -ref_type nt -globalrounds 2 -hsize 25 -NO_CNT_MERGE

 \$denovo2/assemble.pl reads_f3.csfasta reads_f3.qual 200000 -r3 reads_r3.csfasta reads_r3.qual
  -outdir asmb2 -ins_length 3500 -ins_length_sd 700

 \$denovo2/assemble.pl reads_f3.csfasta none 300000 -r3 reads_r3.csfasta -outdir asmb3
  -ins_length 1200 -ins_length_sd 200 -ref_file reference.fasta -ref_type de2
  
 \$denovo2/assemble.pl reads_f3.csfasta none 400000 -f5 reads_f5.csfasta -outdir asmb4
  -ins_length 170 -ins_length_sd 30  
 
 \n";
 
 exit(1);
}

# De novo pipeline parameters
my $reads_file  = shift @ARGV;
my $qual_file = shift @ARGV;
my $refLength = shift @ARGV;
my $r3 = "";
my $r3qv = "";
my $r3t = "";
my $r3qvt = "";
my $NO_CORRECTION = 0;
my $NO_BASE_SPACE = 0;
my $NO_SAMPLING = 0;
my $ASSEMBLE_ONLY = 0;
my $NO_CNT_MERGE = 0;
my $NO_ANALYSIS = 0;

my $outdir="assembly";
my $maxcov = 300;
my $maxcovt = "";
my $read_length = 0;
my $log = "";

# error correction parameters
my $globalrounds = "";
my $localrounds = "";
my $trustprefix = "";
my $trustfreq = "";
my $suppvotes = "";
my $numcores = 1;

# Velvet parameters
my $hsize = 7;
my $exp_cov = "";
my $cov_cutoff = "";
my $min_contig_lgth = "";
my $min_asid = 100;
my $run_type = "fragment";
my $ins_length = "";
my $ins_length_sd = "";
my $min_pair_count = "";
my $insertlen = 0;

# Analysis pipeline parameters
my $ref_file = "";
my $ref_type = ""; # de - double encoded, nt - base space, color - color space, de2 - double encoded forward + reverse

my $opt;
my $nc;

#Initializing input parameters
#*************************************************************************
while ($#ARGV >= 0) {
		$opt   = shift @ARGV;
		if ($opt =~ /^\-/) {
				if ($opt eq "-outdir") {
						$outdir = shift @ARGV;
        }
    	  elsif ($opt eq "-r3" || $opt eq "-f5") {
						$r3 = shift @ARGV;
						$r3t = "-r3 $r3";
						$run_type = "mates";
						if ($opt eq "-f5"){
						$run_type = "paired";
						}
        }
        elsif ($opt eq "-log") {
						$log = "-log";
        }
    	  elsif ($opt eq "-r3qv" || $opt eq "-f5qv")  {
						$r3qv = shift @ARGV;
						$r3qvt = "-r3qv $r3qv";
        }
    	  elsif ($opt eq "-maxcov") {
						$maxcov = shift @ARGV;
						$maxcovt = "-maxcov $maxcov";
        }        
    	  elsif ($opt eq "-ins_length") {
						$insertlen = shift @ARGV;
						$ins_length = "-ins_length $insertlen";
        }                
    	  elsif ($opt eq "-read_length") {
						$read_length = shift @ARGV;
        } 
    	  elsif ($opt eq "-numcores") {
						$numcores = shift @ARGV;
        } 
    	  elsif ($opt eq "-ins_length_sd") {
						my $v = shift @ARGV;
						$ins_length_sd = "-ins_length_sd $v";
        }                
    	  elsif ($opt eq "-exp_cov") {
						my $v = shift @ARGV;
						$exp_cov = "-exp_cov $v";
        }        
    	  elsif ($opt eq "-cov_cutoff") {
						my $v = shift @ARGV;
						$cov_cutoff = "-cov_cutoff $v";
        }        
        elsif ($opt eq "-min_contig_lgth") {
						$min_asid = shift @ARGV;
						$min_contig_lgth = "-min_contig_lgth $min_asid";
        }    
        elsif ($opt eq "-localrounds") {
						my $v = shift @ARGV;
						$localrounds = "-localrounds $v";
        }  
        elsif ($opt eq "-trustprefix") {
						my $v = shift @ARGV;
						$trustprefix = "-trustprefix $v";
        }  
        elsif ($opt eq "-min_pair_count") {
						my $v = shift @ARGV;
						$trustprefix = "-min_pair_count $v";
        }                  
        elsif ($opt eq "-trustfreq") {
						my $v = shift @ARGV;
						$trustfreq = "-trustfreq $v";
        } 
        elsif ($opt eq "-suppvotes") {
						my $v = shift @ARGV;
						$suppvotes = "-suppvotes $v";
        }         
        elsif ($opt eq "-globalrounds") {
						my $v = shift @ARGV;
						$globalrounds = "-globalrounds $v";
        }      
        elsif ($opt eq "-ref_file") {
						my $v = shift @ARGV;
						$ref_file = "-ref_file $v";
        }                          
        elsif ($opt eq "-ref_type") {
						my $v = shift @ARGV;
						$ref_type = "-ref_type $v";
        }                          
    	  elsif ($opt eq "-hsize") {
						$hsize = shift @ARGV;
        }           
				elsif ($opt eq "-NO_SAMPLING") {
						$NO_SAMPLING = 1;
				}		
				elsif ($opt eq "-NO_CORRECTION") {
						$NO_CORRECTION = 1;
				}
				elsif ($opt eq "-ASSEMBLE_ONLY") {
						$ASSEMBLE_ONLY = 1;
				}	
				elsif ($opt eq "-NO_CNT_MERGE") {
						$NO_CNT_MERGE = 1;
				}			
				elsif ($opt eq "-NO_BASE_SPACE") {
						$NO_BASE_SPACE = 1;
				}								
				elsif ($opt eq "-NO_ANALYSIS") {
						$NO_ANALYSIS = 1;
				}			
				else
				{
				 print "Bad option: $opt\n";
				 print "call assemble.pl with no parameters for help.\n";
         exit(1);
				}							
		}
}


if($r3 ne "" and $ins_length eq "")
{
  print "Please provide expected insert size\n";
  exit(1);
}

if($r3 ne "" and $ins_length_sd eq "")
{
  print "Please provide standard deviation of expected insert size\n";
  exit(1);
}

if($NO_SAMPLING == 1 or $ASSEMBLE_ONLY == 1)
{
 if($maxcovt eq "")
 {print "Please provide an accurate estimation of the coverage ( -maxcov xx ).\n"; exit(1); }
 if($read_length == 0)
 {print "Please provide read length ( -read_length xx ).\n"; exit(1); }
}

if($NO_ANALYSIS == 0 and ((ref_type eq "" and ref_file ne "") or (ref_type ne "" and ref_file eq "")))
{
 print "Please provide both ref_file and ref_type. Or exclude both."; exit(1); 
}

# Random sampling of reads for large datasets
#********************************************************************
my $datareduced = "0";
if($NO_SAMPLING == 0 and $ASSEMBLE_ONLY == 0){
print "Run Reads Sampling. \n";
 my $SampleCmd = "mkdir -p $outdir;${exeUTILS}/rsampling ${reads_file} ${qual_file} ${refLength} -outdir $outdir $r3t $r3qvt $maxcovt $log";
 print "$SampleCmd\n";
 
 my $res = log_system($SampleCmd);   
 if ($res != 0) {
  print "Sampling Failed: $res\n";
  unlink("$outdir/.param");
  exit(1);
 }
 else
 {
 open (PRM_FILE, "$outdir/.param") or die "Cannot open the param file $prmf: $!\n";
 ($datareduced, $maxcov, $read_length) = split(' ',<PRM_FILE>);
  close PRM_FILE;
 unlink("$outdir/.param");
 }
}

if($maxcov < 5 or $read_length<20) {print "WARNING: maxcov: $maxcov and read_length: $read_length .\n"; $NO_CORRECTION=1; }
if($maxcov < 15) {print "WARNING: maxcov: $maxcov < 15, Error Correction is turned OFF .\n"; $NO_CORRECTION=1; }


# Perform Error Correction
#***************************************************************************
if($NO_CORRECTION==0 && $ASSEMBLE_ONLY == 0)
{

 print "Merging files for error correction \n";
 if($r3 ne ""){
  my $res = 0;
  if($datareduced eq "1")
  {
   $res = log_system("cat $outdir/subreads2.csfasta >> $outdir/subreads.csfasta;rm -f $outdir/subreads2.csfasta;");
  } else
  {
   $res = log_system("mkdir -p $outdir;cp -f $reads_file $outdir/subreads.csfasta; cat $r3 >> $outdir/subreads.csfasta");
  }   
 if ($res != 0) {
  print "Merging files Failed: $res\n";
  exit(1);
 }}
 
 if($r3qv ne ""){
  my $res = 0;
  if($datareduced eq "1")
  {
   $res = log_system("cat $outdir/subreads2.qual >> $outdir/subreads.qual; rm -f $outdir/subreads2.qual");
  } else
  {
   if($qual_file eq "none") {print "ERROR: First qual file is missing \n"; exit(1);}
   $res = log_system("mkdir -p $outdir;cp -f $qual_file $outdir/subreads.qual; cat $r3qv >> $outdir/subreads.qual");
  }   
 if ($res != 0) {
  print "Merging files Failed: $res\n";
  exit(1);
 }}

 print "Running SOLiD Accuracy Enhancer Tool \n";

 if($globalrounds eq "") {$globalrounds = "-globalrounds 2";}
 my $saet_log = "";
 if($log eq "") { $saetlog = "-log $outdir/fixed/saet.log.txt";}
 
 my $tnumcores = "";
 if($numcores>1){$tnumcores="-numcores $numcores";}

 my $saet = "${exeSAET}/saet_mp";
 if (-e $saet){} else { print "error correction code is not installed!"; exit(1);}
 
 my $errorCorrectReadsCmd = "mkdir -p $outdir;$saet ${reads_file} ${qual_file} ${refLength} -fixdir $outdir/fixed $globalrounds $localrounds $trustfreq $tnumcores $trustprefix $suppvotes $saetlog ";
  
 if($r3 ne "" or $datareduced eq "1") {
 if($qual_file eq "none"){
  $errorCorrectReadsCmd = "$saet $outdir/subreads.csfasta none ${refLength} -fixdir $outdir/fixed $globalrounds $localrounds $trustfreq $tnumcores $trustprefix $suppvotes $saetlog"; }
 else
 { $errorCorrectReadsCmd = "$saet $outdir/subreads.csfasta $outdir/subreads.qual ${refLength} -fixdir $outdir/fixed $globalrounds $localrounds $trustfreq $tnumcores $trustprefix $suppvotes $saetlog "; }
 }
 
 print "$errorCorrectReadsCmd\n";
 my $res = log_system($errorCorrectReadsCmd);   
 if ($res != 0) {
  print "SOLiD Accuracy Enhancer Failed: $res\n";
  exit(1);
}
}

#Preparing input for Velvet
#********************************************************************************
if($ASSEMBLE_ONLY == 0){
 print "Preparing Input for Velvet \n";
 my $preprocessingCmd = "";
 
 if($datareduced eq "1"){
  if($NO_CORRECTION==0){
   if($run_type eq "fragment"){
     $preprocessingCmd = "${exeUTILS}/solid_denovo_preprocessor_v1.2.pl  --run_type $run_type --output $outdir/preprocessor --f3_file $outdir/fixed/subreads.csfasta;"; 
   } else
   {
     $preprocessingCmd = "${exeUTILS}/solid_denovo_preprocessor_v1.2.pl  --run_type $run_type --output $outdir/preprocessor --mixed_tag_file $outdir/fixed/subreads.csfasta;"; 
   }
   }
   else
   {
   if($run_type eq "fragment"){
     $preprocessingCmd = "${exeUTILS}/solid_denovo_preprocessor_v1.2.pl  --run_type $run_type --output $outdir/preprocessor --f3_file $outdir/subreads.csfasta;"; 
   } else
   {
     $preprocessingCmd = "${exeUTILS}/solid_denovo_preprocessor_v1.2.pl  --run_type $run_type --output $outdir/preprocessor --f3_file $outdir/subreads.csfasta  --r3_file $outdir/subreads2.csfasta;"; 
   }   
   }
   } else
   {
   if($NO_CORRECTION==0){
   if($run_type eq "fragment"){
     $preprocessingCmd = "${exeUTILS}/solid_denovo_preprocessor_v1.2.pl  --run_type $run_type --output $outdir/preprocessor --f3_file $outdir/fixed/$reads_file;"; 
   } else
   {
     $preprocessingCmd = "${exeUTILS}/solid_denovo_preprocessor_v1.2.pl  --run_type $run_type --output $outdir/preprocessor --mixed_tag_file $outdir/fixed/subreads.csfasta;"; 
   }
   }
   else
   {
   if($run_type eq "fragment"){
     $preprocessingCmd = "${exeUTILS}/solid_denovo_preprocessor_v1.2.pl  --run_type $run_type --output $outdir/preprocessor --f3_file $reads_file;"; 
   } else
   {
     $preprocessingCmd = "${exeUTILS}/solid_denovo_preprocessor_v1.2.pl  --run_type $run_type --output $outdir/preprocessor --f3_file $reads_file  --r3_file $r3;"; 
   }   
   }
   }
 
 print "$preprocessingCmd \n";  
 my $res = log_system($preprocessingCmd);   
 if ($res != 0) {
  print "Preprocessing Failed: $res\n";
  exit(1);
}
} 

# Running Velvet Assemler
#********************************************************************
print "Running Velvet Assembly \n";

if($hsize == 7)
                   {
                   my $pw = $read_length/25;
                   $hsize = ceil(log(($maxcov**$pw)*$refLength/0.001)/log(4))-1;
                   }
                   if($hsize > 31) {$hsize = 31;}
                   if($hsize > $read_length-3) {$hsize=$read_length-3;}
                  
if($min_contig_lgth eq ""){
                   $min_asid = ceil(2.0*($read_length));
                   $min_contig_lgth = "-min_contig_lgth $min_asid";
                   }
if($exp_cov eq ""){
                   my $ec = ceil(($maxcov)*0.5);
                   $exp_cov = "-exp_cov $ec";
                   }
if($cov_cutoff eq ""){
                   my $ct = ceil(($maxcov)*0.03 + 2); # assuming that error rate is 3%
                   $cov_cutoff = "-cov_cutoff $ct";
                   }                   
if($min_pair_count eq "")
                   {
                    my $ec = ceil(($maxcov)*0.4);
                    if($run_type eq "paired"){ 
                    $ec = ceil(($maxcov)*0.03 + 2); # assuming that error rate is 3%
                    }
                    $min_pair_count = "-min_pair_count $ec";
                    }

my $amos = "-read_trkg yes";

  if($NO_BASE_SPACE==1) { $amos = ""; }
  
my $assembleGlobalScaffoldsCmd = 
    "${exeVELVET}/velveth_de $outdir/velvet $hsize -fasta -short $outdir/preprocessor/doubleEncoded_input.de;
     ${exeVELVET}/velvetg_de $outdir/velvet $min_contig_lgth $exp_cov $cov_cutoff $amos;";   

   if($run_type eq "mates" || $run_type eq "paired"){
$assembleGlobalScaffoldsCmd = 
    "${exeVELVET}/velveth_de $outdir/velvet $hsize -fasta -shortPaired $outdir/preprocessor/doubleEncoded_input.de;
     ${exeVELVET}/velvetg_de $outdir/velvet $ins_length  $ins_length_sd $min_contig_lgth $exp_cov $cov_cutoff $min_pair_count $amos;";   
}

 print "$assembleGlobalScaffoldsCmd \n";
 my $res = log_system($assembleGlobalScaffoldsCmd);   
 if ($res != 0) {
  print "Assembly Failed: $res\n";
  exit(1);
}

#*******************************************************************
{
 my $res = log_system("mkdir -p $outdir/postprocessor;mkdir -p $outdir/postprocessor/gap_reads;");   
 if ($res != 0) {
  print "creating of postprocessor directory failed: $res\n";
  exit(1);
}}

## Contigs Merging by Local Assembly
#*******************************************************************
if($NO_CNT_MERGE == 0 && $run_type ne "fragment")
{
 print "Running Assisted Assembly for SOLiD \n";
 my $extractGapReadsCmd = "${exeASiD}/asid_light -collect $outdir/velvet/LastGraph $outdir/velvet/contigs.fa $outdir/velvet/Sequences ${insertlen} $outdir/postprocessor/gap_reads";
 print "$extractGapReadsCmd \n";
 my $res = log_system($extractGapReadsCmd);   
 if ($res != 0) {
  print "Contigs merging failed when extracting gap reads.\n";
  exit(1);
}

 my $ct1 = ceil(($maxcov)*0.03 + 2);
  my $ct2 = ceil(($ct1)*0.8);
   my $ct3 = ceil(($ct1)*0.6);
    my $ct4 = ceil(($ct1)*0.5);
 my $ec1 = ceil(($maxcov)*0.7);
 my $ec2 = ceil(($maxcov)*0.5);
 my $assembleGapsCmd1 = "${exeASiD}/asid_assembly.sh $outdir/postprocessor/gap_reads/ 13 60 ${ec1} ${ct1} ${numcores} 1 ";
 my $assembleGapsCmd2 = "${exeASiD}/asid_assembly.sh $outdir/postprocessor/gap_reads/ 15 60 ${ec1} ${ct2} ${numcores} 2 ";
 my $assembleGapsCmd3 = "${exeASiD}/asid_assembly.sh $outdir/postprocessor/gap_reads/ 19 60 ${ec2} ${ct3} ${numcores} 3 ";
 my $assembleGapsCmd4 = "${exeASiD}/asid_assembly.sh $outdir/postprocessor/gap_reads/ 21 60 ${ec2} ${ct4} ${numcores} 4 ";

 print "$assembleGapsCmd1 \n";
my $res = log_system($assembleGapsCmd1);   
 if ($res != 0) {
  print "Contigs merging failed when assembling local reads.\n";
  exit(1);
}

 print "$assembleGapsCmd2 \n";
 my $res = log_system($assembleGapsCmd2);   
 if ($res != 0) {
  print "Contigs merging failed when assembling local reads.\n";
  exit(1);
}

 print "$assembleGapsCmd3 \n";
 my $res = log_system($assembleGapsCmd3);   
 if ($res != 0) {
 print "Contigs merging failed when assembling local reads.\n";
 exit(1);
}

 print "$assembleGapsCmd4 \n";
 my $res = log_system($assembleGapsCmd4);   
 if ($res != 0) {
 print "Contigs merging failed when assembling local reads.\n";
 exit(1);
}

 my $fillGapsCmd = "${exeASiD}/asid_light -merge $outdir/velvet/LastGraph $outdir/velvet/contigs.fa $outdir/preprocessor/colorspace_input.csfasta $outdir/postprocessor/colorspace_input.idx $outdir/postprocessor/gap_reads/ $outdir/postprocessor/color_reads.ma $outdir/asid_scaffolds.de fixed2de $min_asid $run_type";
 
 if($NO_BASE_SPACE == 0)
 { 
  $fillGapsCmd = "${exeASiD}/asid_light -merge $outdir/velvet/LastGraph $outdir/velvet/contigs.fa $outdir/preprocessor/colorspace_input.csfasta $outdir/postprocessor/colorspace_input.idx $outdir/postprocessor/gap_reads/ $outdir/postprocessor/color_reads.ma $outdir/asid_scaffolds.de fixed2ma $min_asid $run_type";
 }
 
 print "$fillGapsCmd \n";
 my $res = log_system($fillGapsCmd);   
 if ($res != 0) {
  print "Contigs merging failed when filling the gaps.\n";
  exit(1);
}

 if($NO_BASE_SPACE == 0)
 { 
  $convertMAtoBaseCmd = "${exeASiD}/asid_light -convert $outdir/postprocessor/color_reads.ma 70 > $outdir/postprocessor/asid_ntcontigs.tmp";
  
  print "$convertMAtoBaseCmd \n";
  my $res = log_system($convertMAtoBaseCmd);   
 if ($res != 0) {
  print "Contigs merging failed when converting contigs into base-space.\n";
  exit(1);
}

  $mergeBaseContigsCmd = "${exeASiD}/asid_light -combine $outdir/postprocessor/asid_ntcontigs.tmp $outdir/nt_contigs.fa $outdir/nt_scaffolds.fa 70 $min_asid";

  print "$mergeBaseContigsCmd \n";
  my $res = log_system($mergeBaseContigsCmd);   
 if ($res != 0) {
  print "Contigs merging failed oa a final merge.\n";
  exit(1);
}
}

}

## Post processing / Convertion to base space
#*******************************************************************
elsif($NO_BASE_SPACE == 0)
{

 my $graph2ma = "${exeASiD}/asid_light -merge $outdir/velvet/LastGraph $outdir/velvet/contigs.fa $outdir/preprocessor/colorspace_input.csfasta $outdir/postprocessor/colorspace_input.idx $outdir/postprocessor/gap_reads/ $outdir/postprocessor/color_reads.ma $outdir/asid_scaffolds.de graph2ma $min_asid $run_type";

 print "$graph2ma \n";
 my $res = log_system($graph2ma);   
 if ($res != 0) {
  print "Graph converion into base space failed.\n";
  exit(1);
}

 $convertMAtoBaseCmd = "${exeASiD}/asid_light -convert $outdir/postprocessor/color_reads.ma 70 > $outdir/nt_contigs.fa";
  
  print "$convertMAtoBaseCmd \n";
  my $res = log_system($convertMAtoBaseCmd);   
 if ($res != 0) {
  print "Graph converion into base space failed.\n";
  exit(1);
}
}

#*******************************************************************
# Successful Execution

print "Assembly Pipeline ran successfuly.\n";
log_system("cp $outdir/velvet/contigs.fa $outdir/contigs.de");
print "Double-Encoded contigs (A=0,C=1,G=2,T=3): $outdir/contigs.de\n";
if($NO_CNT_MERGE == 0 && $run_type ne "fragment" ){ 
if($NO_BASE_SPACE == 0) {
                         print "Base-space merged scaffolds: $outdir/nt_scaffolds.fa\n";
                         print "Base-space merged contigs: $outdir/nt_contigs.fa\n";}
else{print "Double-Encoded merged scaffolds: $outdir/asid_scaffolds.de\n";}
}
elsif($NO_BASE_SPACE == 0) { print "Base-space contigs: $outdir/nt_contigs.fa\n"; }


#*******************************************************************
# Running Analysis Pipeline

if($NO_ANALYSIS == 0)
 {
 print "run analysis.\n";

 mkdir("$outdir/analysis",0777);

 if (-e "$outdir/velvet/contigs.fa")
 {
 my $scaffoldCmd = "${exeDeNovo}/analyze.pl $outdir/velvet/contigs.fa $ref_file $ref_type -outdir $outdir/analysis/scaffolds -cont_type de"; 
 if($run_type eq "fragment"){$scaffoldCmd = "${exeDeNovo}/analyze.pl $outdir/velvet/contigs.fa $ref_file $ref_type -outdir $outdir/analysis/contigs -cont_type de"; }
 print "$scaffoldCmd \n";
 my $res = log_system($scaffoldCmd);   
 }

 if($run_type ne "fragment"){
   
    if (-e "$outdir/velvet/contigs.fa")
    {
     my $contigCmd = "${exeDeNovo}/analyze.pl $outdir/velvet/contigs.fa $ref_file $ref_type -outdir $outdir/analysis/contigs -cont_type de -break_scaf"; 
     print "$contigCmd \n";
     $res = log_system($contigCmd); 
    }

    if (-e "$outdir/nt_scaffolds.fa")
    {
     my $mergescaffoldCmd = "${exeDeNovo}/analyze.pl $outdir/nt_scaffolds.fa $ref_file $ref_type -outdir $outdir/analysis/nt_scaffolds -cont_type nt"; 
     print "$mergescaffoldCmd \n";
     my $res = log_system($mergescaffoldCmd);   

    } 
 }
 if (-e "$outdir/nt_contigs.fa")
 {
 my $baseCmd = "${exeDeNovo}/analyze.pl $outdir/nt_contigs.fa $ref_file $ref_type -outdir $outdir/analysis/nt_contigs -cont_type nt"; 
 print "$baseCmd \n";
 $res = log_system($baseCmd); 
 }
  if (-e "$outdir/asid_scaffolds.de")
 {
 my $baseCmd = "${exeDeNovo}/analyze.pl $outdir/asid_scaffolds.de $ref_file $ref_type -outdir $outdir/analysis/asid_scaffolds -cont_type de"; 
 print "$baseCmd \n";
 $res = log_system($baseCmd); 
  my $baseCmd = "${exeDeNovo}/analyze.pl $outdir/asid_scaffolds.de $ref_file $ref_type -outdir $outdir/analysis/asid_contigs -cont_type de -break_scaf"; 
 print "$baseCmd \n";
 $res = log_system($baseCmd); 
 }
 
 } 
#******************************************************************* 

close LOG
