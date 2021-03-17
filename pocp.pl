use strict;
use warnings;

#### usage: perl pocp.pl blastpfile ####

####VARIABLES####
my $line;
my $lineq;
my $lines;
my $liner;
my $query;
my $queryfile;
my $subject;
my $subjectfile;
my $outfile;
my $recipfile;
my $gene;
my $pctid;
my $alnlen;
my $qlen;
my $pctcoverage;
my $eval;
my $c_one=0;
my $c_two=0;
my $t_one=0;
my $t_two=0;
my $pocp=0;

####FILES####
my $infile=shift;
open FILE, "$infile" or die$!;

if($infile=~/(.*)v(.*)blastpresults\.txt/){
    $subject=$1;
    $subjectfile=$subject."_lengths.txt";
    $query=$2;
    $queryfile=$query."_lengths.txt";
}

$recipfile=$query."v".$subject."blastpresults.txt";
open RECIP, "$recipfile" or die$!; 

#print "$subject, $query, $subjectfile, $queryfile, $recipfile"; 
open OUT, ">>pocp_output.txt" or die$!;

#### Calculate number of conserved prots in SUBJECT GENOME ####

while($line=<FILE>){
    if($line=~/(.*)\t.*\t(.*)\t(.*)\t.*\t.*\t.*\t.*\t.*\t.*\t(.*)\t.*/){
	$gene=$1;
	$pctid=$2;
	$alnlen=$3;
	$eval= $4;
	#print "$gene, $pctid, $alnlen, $eval\n";
	open QUERY, "$queryfile" or die$!;
	while($lineq=<QUERY>){
	    if($lineq=~/$gene\t(\d+)/){
		$qlen=$1;
		#print "$queryfile, $qlen\n";
	       
	    }
	}
	close QUERY;
	$pctcoverage=$alnlen/$qlen;
	#print "$gene, $alnlen, $qlen,  $pctcoverage, $pctid, $eval\n";
	if($pctcoverage>=0.40 && $pctid>=50 && $eval<=1e-5){
	    #print "$gene, $pctcoverage, $pctid, $eval\n"; 
	    $c_one=$c_one+1;
	}
    }
}

#### Calculate number of conserved prots in QUERY GENOME ####


while($liner=<RECIP>){
    if($liner=~/(.*)\t.*\t(.*)\t(.*)\t.*\t.*\t.*\t.*\t.*\t.*\t(.*)\t.*/){
        $gene=$1;
        $pctid=$2;
        $alnlen=$3;
        $eval= $4;
        #print "$gene, $pctid, $alnlen, $eval\n";                                                                                          
        open SUB, "$subjectfile" or die$!;
        while($lines=<SUB>){
            if($lines=~/$gene\t(\d+)/){
                $qlen=$1;
                #print "$queryfile, $qlen\n";                                                                                             
            }
        }
        close SUB;
        $pctcoverage=$alnlen/$qlen;
        #print "$gene, $alnlen, $qlen,  $pctcoverage, $pctid, $eval\n";                                                                    
        if($pctcoverage>=0.40 && $pctid>=50 && $eval<=1e-5){
	    #print "$gene, $pctcoverage, $pctid, $eval\n";
	    $c_two=$c_two+1;
        }
    }
}

#### Calculate total prots ####
$t_one= `wc -l $queryfile | cut -d " " -f 1 `;
chomp $t_one;
$t_two=`wc -l $subjectfile | cut -d " " -f 1 `;
chomp $t_two;


#### Calculate POCP ####
$pocp=(($c_one+$c_two)/($t_one+$t_two))*100;

#### Print Results ####
print "Number of Conserved Proteins (C1) in $query:\t$c_one\n";
print "Number of Conserved Proteins (C2) in $subject:\t$c_two\n";
print "Number of Total Proteins in $query:\t$t_one\n";
print "Number of Total Proteins in $subject:\t$t_two\n";
print "POCP FORMULA=((C1+C2)/(T1+T2))*100\n";
print "POCP VALUE= $pocp\n";

print OUT "Query: $query Subject: $subject POCP: $pocp\n"; 
