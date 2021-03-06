#!/usr/bin/perl

=head1 NAME

wispr.cgi - front-end to pf::web::wispr

=head1 DESCRIPTION

See L<pf::web::wispr> for details.

=cut

use strict;
use warnings;

use lib '/usr/local/pf/lib';

use Log::Log4perl;

use pf::Portal::Session;
use pf::web::wispr;
# called last to allow redefinitions
use pf::web::custom;

my $portalSession = pf::Portal::Session->new();

pf::web::wispr::generate_redirect($portalSession);

=head1 AUTHOR

Olivier Bilodeau <obilodeau@inverse.ca>

Derek Wuelfrath <dwuelfrath@inverse.ca>
        
=head1 COPYRIGHT
        
Copyright (C) 2011, 2012 Inverse inc.
    
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
