#!/usr/bin/env perl
# Last changed Time-stamp: <2015-02-05 23:19:17 mtw>
# AUTHOR: Joerg Fallmann <joerg.fallmann@univie.ac.at>

###############
###Use stuff
###############
use strict;
use warnings;
use Cwd;
use Getopt::Long qw( :config posix_default bundling no_ignore_case );
use Pod::Usage;
use File::Path qw(make_path remove_tree);
use Math::Round;
use Bio::ViennaNGS::Bam qw(split_bam);
use Bio::ViennaNGS::Util qw(parse_bed6 extend_chain kmer_enrichment fetch_chrom_sizes bed_or_bam2bw);
use Bio::ViennaNGS::Feature;
use Bio::ViennaNGS::FeatureChain;
use List::Util qw(sum);
use Data::Dumper;
use IPC::Cmd qw(can_run run);
###############
###Variables
###############

my $VERBOSE = 0;
my ($r,$RLIBPATH)=('','');

###############
###Command Line Options
###############
Getopt::Long::config('no_ignore_case');
pod2usage(-verbose => 0) unless GetOptions(
    "rpath|r=s" => \$RLIBPATH,
    "help|h"    => sub{pod2usage(-verbose => 1)},
    "man|m"     => sub{pod2usage(-verbose => 2)},
    "verbose"   => sub{ $VERBOSE++ }
    );

###############
### MAIN
###############

=head1 NAME

Tutorial_Pipeline02.pl - Another example pipeline for the ViennaNGS
toolbox

=head1 SYNOPSIS

  perl Tutorial_Pipeline02.pl

=head1 DESCRIPTION

This script is a showcase for using Bio::ViennaNGS components with a
real-world NGS example.

We start from a file containing ENSEMBL annotation information for
human protein-coding genes, which have a read pileup of at least 1001
reads in an ENCODE dataset mapped with segemehl. We are insterested in
generating a UCSC Track Hub visualizing those genes as well as a 50nt
region upstream of the gene start.

=head2 DISCLAIMER

This tutorial works on a real-world biological data set of several
gigabytes in size i.e. the analysis will eventually take a few hours
to finish. If you run this script locally you need to ensure that your
system has enough hardware resources.

=head1 PIPELINE

Let's first initialize some variables and generate a chromosome_sizes
hash.

  my $bed       = 'hg19_highlyexpressed.bed';
  my $name      = (split(/\./,$bed))[0];
  my $upstream  = 50;
  my $outfile2  = "$name.ext$upstream\_upstream.bed";
  my %sizes     = %{fetch_chrom_sizes('hg19')};

=cut

my $bed	      = 'hg19_highlyexpressed.bed';
my $name      = (split(/\./,$bed))[0];
my $upstream  = 50;
my $outfile   = "$name.ext$upstream\_upstream.bed";
my %sizes     = %{fetch_chrom_sizes('hg19')}; ### Requires installation of UCSCs fetchChromSizes script or mysql

=head3 Generate a Bio::ViennaNGS::FeatureChain object

We'll now parse our BED file of interest, generate a feature array and
pass it on to L<Bio::ViennaNGS::FeatureChain>, thereby creating a new
I<FeatureChain> L<Moose> object that contains the original BED
entries.

  my @featurelist  = @{parse_bed6($bed)};
  my $chain        = Bio::ViennaNGS::FeatureChain->new('type'=>'original','chain'=>\@featurelist);

=cut

my @featurelist = @{parse_bed6($bed)};
my $chain	= Bio::ViennaNGS::FeatureChain->new('type'=>'original','chain'=>\@featurelist);

=head3 Extend the existing chain for UCSC visualization

The I<FeatureChain> object will now be extended 50nt upstream of the
gene start to retrieve a BED file containing both the genic and
potential promoter regions.

  my $extended_chain = extend_chain(\%sizes,$chain,$upstream,0,0,0);

We'll also extend the entire U6 gene span 50nt upstream for later usage.

  my $extended_chain2 = extend_chain(\%sizes,$chain,$upstream,0,0,0);

=cut

my $extended_chain = extend_chain(\%sizes,$chain,$upstream,0,0,0);

=head3 Print extended Bio::ViennaNGS::FeatureChain objects to files

Extended chains are now printed out to make them available for
external tools like bedtools.

  my $out = $extended_chain->print_chain();
  print $Out $out;
  close($Out);

=cut


open (my $Out, ">",$outfile) or die "$!";

my $out = $extended_chain->print_chain();
print $Out $out;

close($Out);

=head3 Summary of so far used methods

=over 4

=item C<fetch_chrom_sizes()>

Returns a chromosome-sizes hash reference for the specified species,
e.g. hg19, mm9, mm10, etc.

=item C<parse_bed6()>

Reads a bed6 file and returns a feature array.

=item C<Bio::ViennaNGS::FeatureChain->new()>

Generates a new Bio::ViennaNGS::FeatureChain object from a feature
array

=item C<extend_chain()>

Extends a Bio::ViennaNGS::FeatureChain object by given constraints

=back

=cut

=head2 Sequence processing and analysis

We will now generate FASTA files from the extended BED files by using
the I<bedtools getfasta> method.

  $bedtools = `bedtools getfasta -s -fi hg19_chromchecked.fa -bed $outfile2 -fo $name.ext$upstream\_upstream.fa`;
  print STDERR "$bedtools\n" if $?;

To analyze putative sequence motifs in the newly generated Fasta
files, we analyze the k-mer content using the C<Bio::ViennaNGS>
C<kmer_enrichment()> method for k-mers of length 6 to 8 nt.

 open(IN,"<","$name.ext$upstream\_upstream.fa") || die ("Could not open $name.ext$upstream\_upstream.fa!\n@!\n");

  my @fastaseqs;
  while(<IN>){
    chomp (my $raw = $_);
    next if ($_ =~ /^>/);
    push @fastaseqs, $raw;
  }
  close(IN);

  for (6..8){
    my %kmer = %{kmer_enrichment(\@fastaseqs, $_)};
    my $total = sum values %kmer;
    ### Print Output
    open(KMER,">","$_\_mers") or die "Could not open file $_\_mers$!\n";
    print KMER "$_\-mer\tCount\tRatio\n";
    print KMER "TOTAL\t$total\t1\n";
    foreach my $key  (sort {$kmer{$b} <=> $kmer{$a} } keys %kmer) {
      my $ratio = nearest(.0001,$kmer{$key}/$total);
      print KMER "$key\t$kmer{$key}\t$ratio\n";
    }
    close(KMER);
  }

=cut

my $bedtools = `bedtools getfasta -s -fi hg19_chromchecked.fa -bed $outfile -fo $name.ext$upstream\_upstream.fa`;
print STDERR "$bedtools\n" if $?;

open(IN,"<","$name.ext$upstream\_upstream.fa") || die ("Could not open $name.ext$upstream\_upstream.fa!\n@!\n");

my @fastaseqs;
while(<IN>){
    chomp (my $raw = $_);
    next if ($_ =~ /^>/);
    push @fastaseqs, $raw;
}
close(IN);

for (6..8){
    my %kmer = %{kmer_enrichment(\@fastaseqs, $_)};
    my $total = sum values %kmer;
    ### Print Output
    open(KMER,">","$_\_mers") or die "Could not open file $_\_mers$!\n";
    print KMER "$_\-mer\tCount\tRatio\n";
    print KMER "TOTAL\t$total\t1\n";
    foreach my $key  (sort {$kmer{$b} <=> $kmer{$a} } keys %kmer) {
	my $ratio = nearest(.0001,$kmer{$key}/$total);
	print KMER "$key\t$kmer{$key}\t$ratio\n";
    }
    close(KMER);
}

=head3 Retrieve mapped sequences that overlap the extended chain as BAM using I<bedtools>

To generate a BAM file containing uniquely mapped reads that overlap
our genes of interest, we use the I<bedtools intersect> method.

  my $bam_upstream = "hg19_highlyexpressed.ext50_upstream_overlapping_C1R1.bam";
  my $cmd = "intersectBed -s -split -abam C1R1.bam -b hg19_highlyexpressed.ext50_upstream.bed > $bam_upstream ";
  my( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf ) = run(command => $cmd, verbose => 0);

  if(!$success){
    my $this_function = (caller(0))[3];
    print STDERR "ERROR: Bedtools intersect unsuccessful\n";
    print join "", @$full_buf;
  }

=cut

my $bam_upstream = "hg19_highlyexpressed.ext50_upstream_overlapping_C1R1.bam";
my $cmd = "intersectBed -s -split -abam C1R1.bam -b hg19_highlyexpressed.ext50_upstream.bed > $bam_upstream ";
my( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf ) = run(command => $cmd, verbose => 0);

if(!$success){
  my $this_function = (caller(0))[3];
  print STDERR "ERROR: Bedtools intersect unsuccessful\n";
  print join "", @$full_buf;
}


=head3 Split BAM by strand

We will now split the BAM file by strands using the C<bam_split()>
routine, thereby creating two new BAM files: One containg all reads
mapped to the [+] strand, and one that contains all reads that map to
the [-] strand.

  my $reversed = 1;
  my $wantuniq = 0;
  my $wantbed  = 1;
  my $outdir   = cwd();
  my $lf       = undef;

  my @result = split_bam($bam_upstream,$reversed,$wantuniq,$wantbed,$outdir,$lf);

  my $bam_p  = $result[0]; # BAM file containing fragments of [+] strand
  my $bam_n  = $result[1]; # BAM file containing fragments of [-] strand
  my $size_p = $result[2]; # of alignments on [+] strand
  my $size_n = $result[3]; # of alignments on [-] srand
  my $bed_p  = $result[4]; # BED file containing fragments of [+] strand
  my $bed_n  = $result[5]; # BED file containing fragments of [-] strand

C<bam_split> returns an array, (C<@ref> in our example) that contains
six fields: The paths of the BAM files for [+] and [-] strand, number
of alignments in the [+] and [-] BAM files as well as the paths to the
interim BED files for [=] and [-] strand, respectively.

=cut

my $reversed = 1;
my $wantuniq = 0;
my $wantbed  = 1;
my $outdir   = cwd();
my $lf       = undef;

my @result = split_bam($bam_upstream,$reversed,$wantuniq,$wantbed,$outdir,$lf);

my $bam_p  = $result[0]; # BAM file containing fragments of [+] strand
my $bam_n  = $result[1]; # BAM file containing fragments of [-] strand
my $size_p = $result[2]; # of alignments on [+] strand
my $size_n = $result[3]; # of alignments on [-] srand
my $bed_p  = $result[4]; # BED file containing fragments of [+] strand
my $bed_n  = $result[5]; # BED file containing fragments of [-] strand

=head3 Create BigWig coverage profiles

Now that we have separate BAM files for each strand at hand, the next
step will be to create coverage profiles in BigWig format for
subsequent UCSC visualization. The routine of choice for this task is
C<bed_or_bam2bw()>, which is called separately for [+] and [-] strand.

  my $od       = cwd();
  my $cs_in    = "hg19.chrom.sizes";
  my $wantnorm = 0;
  my $scale    = 10000000;

  bed_or_bam2bw("bed",$bed_p,$cs_in,"+",$od,$wantnorm,$size_p,$scale,$lf);
  bed_or_bam2bw("bed",$bed_n,$cs_in,"-",$od,$wantnorm,$size_n,$scale,$lf);

Once finished, there will be two BigWig files in the current working
directoy, one for each strand. These files can be used for
visualization in a genome browser.

=cut

my $od       = cwd();
my $cs_in    = "hg19.chrom.sizes";
my $wantnorm = 0;
my $scale    = 10000000;

bed_or_bam2bw("bed",$bed_p,$cs_in,"+",$od,$wantnorm,$size_p,$scale,$lf);
bed_or_bam2bw("bed",$bed_n,$cs_in,"-",$od,$wantnorm,$size_n,$scale,$lf);

=head1 COMMAND LINE OPTIONS

=cut

__END__


=over 4

=item B<--help -h>

Print short help

=item B<--man>

Prints the manual page and exits

=back

=head1 AUTHORS

=over

=item Joerg Fallmann E<lt>joerg.fallmann@univie.ac.atE<gt>

=item Michael T. Wolfinger E<lt>michael@wolfinger.euE<gt>

=back

=cut


##################################END################################
