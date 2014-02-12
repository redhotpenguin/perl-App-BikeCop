package App::BikeCop;

our $VERSION = '0.01';

use Moo;
use LWP::UserAgent;
use URI;
use DateTime;
use String::Strip;

has 'craigslist_zone' => (
    is      => 'ro',
    default => 'sfbay',
);

has 'stolenbikereg_state' => (
    is      => 'ro',
    default => 'CA',
);

has 'craigslist_base' => (
    is      => 'ro',
    default => 'http://%s.craigslist.org',
);

has 'craigslist_url' => (
    is      => 'ro',
    default => 'http://sfbay.craigslist.org/search/bik/?s=%d&sort=date',
);

has 'stolenbikereg_url' => (
    is => 'ro',
    default =>
'http://www.stolenbicycleregistry.com/listbikes.php?showby=state&state=%s',
);

has 'ua' => (
    is      => 'ro',
    default => sub {
        LWP::UserAgent->new(
            agent      => __PACKAGE__ . '_' . $VERSION,
            keep_alive => 1,
        );
    }
);

sub find_todays_matches {
    my $self = shift;

    my $today = DateTime->now;
    my $month = $today->month_abbr;
    my $day   = $today->day;
    my $start = 0;

    my $craigslist_res =
      $self->ua->get( sprintf( $self->craigslist_url, $start ) );

    # handle errors
    die $craigslist_res->status_line unless $craigslist_res->is_success;

    # we've got some data
    my $decoded_content = $craigslist_res->decoded_content;

    # poor man's parser
    my ( $head, $content ) = split( '<div class="content">', $decoded_content );
    my ( $rows, $other ) = split( '</div>', $content );
    StripLTSpace($rows);
    my @rows = split( '<\/p>', $rows );

    my @bikes;
    foreach my $row (@rows) {
        my ( $row_month, $row_day ) =
          $row =~ m/<span class="date">(\w+)\s(\d+)<\/span>/;

        # limit to today
        next unless ( $row_month eq $month && $row_day eq $day );

        # grab the post url
        my ( $url, $title ) = $row =~ m/<a href="([^"]+)">([^<]+)</;

        my ($city) = $row =~ m/<small>\s\(([^\)]+)\)/;

        my ($brand) =
          lc($row) =~
m/(trek|specialized|schwinn|giant|bmc|mongoose|haro|litespeed|raleigh)/
          || 'unknown';
        $brand = $1;

        push @bikes,
          {
            url => URI->new(
                sprintf( $self->craigslist_base, $self->craigslist_zone )
                  . $url
            ),
            title => $title,
            city  => $city,
            brand => $brand
          };

        $DB::single = 1;
    }

    return \@bikes;
}

#  <p class="row" data-latitude="37.7765971212103" data-longitude="-122.417417655932" data-pid="4323850090"> <a href="/sfc/bik/4323850090.html" class="i" data-id="0:00M0M_iXDJXEKvAR7"><span class="price">&#x0024;650</span></a> <span class="star"></span> <span class="pl"> <span class="date">Feb 12</span>  <a href="/sfc/bik/4323850090.html">CycleOps Powertap Pro Wireless ANT+ hub (2012) + wheel - NEW condition</a> </span> <span class="l2"> <span class="price">&#x0024;650</span>  <span class="pnr"> <small> (downtown / civic / van ness)</small> <span class="px"> <span class="p"> pic&nbsp;<a href="#" class="maptag" data-pid="4323850090">map</a></span></span> </span>  </span> </p>

1;
__END__
=head1 NAME

App::BikeCop - "Dead or alive, you're coming with me." - RoboCop

=head1 SYNOPSIS

  use App::BikeCop;
  my $bikecop = App::BikeCop->new({ craigslist_zone => 'sfbay', stolenbikereg_state => 'CA' });
  my @matches = $bikecop->find_todays_matches;

  # $match = ( brand => 'Trek',         model => 'Speed Concept',
  #            city => 'San Francisco', zip => '94103',
  #            craigslist => 'http://monterey.craigslist.org/bik/4306728329.html',
  #            stolenbikereg => 'http://www.stolenbicycleregistry.com/showbike.php?oid=18113', );

=head1 DESCRIPTION

This app finds stolen bikes on Craigslist by matching them to the Stolen Bike Registery.


=head1 SEE ALSO

LWP::UserAgent

=head1 AUTHOR

Fred Moyer, E<lt>fred@redhotpenguin.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by Fred Moyer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
