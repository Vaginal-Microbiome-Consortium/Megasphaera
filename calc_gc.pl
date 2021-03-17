
use strict;
use warnings;
use Bio::SeqIO;

die ("Usage: $0 <sequence_file> (output_file>\n"), unless (@ARGV == 2);

my ($infile,$outfile) = @ARGV;
open (OUT,">$outfile");
my $in = Bio::SeqIO->new(-file => $infile, -format => 'fasta');
while (my $seq = $in->next_seq) {
    my $id = $seq->id;
    my $seq_2 = $seq->seq_2;
    my $length = $seq->length;
    my $count = 0;
    for (my $i = 0; $i < $length; $i++) {
	my $sub = substr($seq_2,$i,1);
	if ($sub =~ /G|C/i) {
	    $count++;
	}
    }
    my $gc = sprintf("%.1f",$count * 100 /$length);
    print OUT $id,"\t",$gc,"\n";
}
