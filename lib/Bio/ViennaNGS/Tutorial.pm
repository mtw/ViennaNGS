# -*-CPerl-*-
# Last changed Time-stamp: <2015-02-06 11:37:28 mtw>

package Bio::ViennaNGS::Tutorial;

use Exporter;
use version; our $VERSION = qv('0.12_14');
use strict;
use warnings;

our @ISA = qw(Exporter);
our @EXPORT = ();

our @EXPORT_OK = qw ();

1;
__END__

=head1 NAME

Bio::ViennaNGS::Tutorial - A collection of basic tutorials
demonstrating of the core components and features of the
L<Bio::ViennaNGS> suite

=head1 DESCRIPTION

The L<Bio::ViennaNGS> tutorial is a collection of fully documented
pipeline scripts that have been built as a showcase for the usage of
the L<Bio::ViennaNGS> distribution with real NGS data.

=head2 DISCLAIMER

Many example pipelines covered here work and depend on fairly large
real world NGS data sets in the gigabyte scale. Be prepared that each
tutorial takes a couple of hours of CPU time to finish. When running
the scripts locally you need to ensure that your system has enough
hardware resources available.

=head2 DATA DOWNLOAD

All input data required for the individual tutorial pipelines can be
downloaded from the L<ViennaNGS data
repository|http://nibiru.tbi.univie.ac.at/ViennaNGS/>.

=head1 TUTORIALS

=over

=item L<Tutorial 00|http://search.cpan.org/dist/Bio-ViennaNGS/scripts/Tutorial_pipeline00.pl>: Inferring detailed mapping statistics from BAM files

=item L<Tutorial 01|http://search.cpan.org/dist/Bio-ViennaNGS/scripts/Tutorial_pipeline01.pl>: Finding sequence motifs in close proximity to gene starts in a set of human protein coding genes

=item L<Tutorial 02|http://search.cpan.org/dist/Bio-ViennaNGS/scripts/Tutorial_pipeline02.pl>: Automatic generation of UCSC genome browser Track Hubs for visualization of ENCODE RNA-seq data 

=back


=head1 AUTHORS

=over

=item Michael T. Wolfinger E<lt>michael@wolfinger.euE<gt>

=item Joerg Fallmann E<lt>fall@tbi.univie.ac.atE<gt>

=item Florian Eggenhofer E<lt>florian.eggenhofer@tbi.univie.ac.atE<gt>

=item Fabian Amman E<lt>fabian@tbi.univie.ac.at<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014-2015 Michael T. Wolfinger
E<lt>michael@wolfinger.euE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut


