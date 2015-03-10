#!/usr/bin/perl
=head1 NAME

omapi - test script for checking omapi connections

=cut

=head1 DESCRIPTION

omapi

=cut

use strict;
use warnings;
use lib qw(/usr/local/pf/lib);
use pf::OMAPI;
use Getopt::Long;

my %options = (
    host => 'localhost',
    port => 7911
);

GetOptions (\%options,
    "port=i", "host=s", "keyname=s", "key_base64=s","ip=s"
)  || die "Invalid parameter passed";

die "keyname, key_base64 or ip not provided" unless defined $options{keyname} && defined $options{key_base64} && defined $options{ip};

my $ip = delete $options{ip};

my $omapi = pf::OMAPI->new (\%options);

my $data = $omapi->lookup({type => 'lease'}, { 'ip-address' => $ip });

use Data::Dumper;
Dumper $data;

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2014 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

