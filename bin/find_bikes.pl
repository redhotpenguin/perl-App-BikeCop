#!/usr/bin/perl

use strict;
use warnings;

=head1 NAME

 find_bikes.pl

=head1 SYNOPSIS
  
 find_bikes.pl --craigslist=sfbay --stolenbikereg=CA

=cut

use Getopt::Long;
use Pod::Usage;
use App::BikeCop;
use Data::Dumper;

my ( $craigslist, $stolenbikereg, $help, $man );

pod2usage(1) unless @ARGV;
GetOptions(
    'craigslist=s'    => \$craigslist,
    'stolenbikereg=s' => \$stolenbikereg,
    'help'            => \$help,
    'man'             => \$man,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

my $bikecop = App::BikeCop->new(
    { craigslist_zone => $craigslist, stolenbikereg_state => $stolenbikereg } );

my @matches = $bikecop->find_todays_matches;

print Dumper( \@matches );

1;

__END__

=head1 DESCRIPTION

[DESCRIPTION]

=head1 OPTIONS

=over 4

=item B<opt1>

The first option

=item B<opt2>

The second option

=back

=head1 TODO

=over 4

=item *

Todo #1

=back

=head1 BUGS

None yet

=head1 AUTHOR

[AUTHOR]

=cut

#===============================================================================
#
#         FILE:  find_bikes.pl
#
#        USAGE:  ./find_bikes.pl 
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  02/12/2014 00:41:26 PST
#     REVISION:  ---
#===============================================================================

