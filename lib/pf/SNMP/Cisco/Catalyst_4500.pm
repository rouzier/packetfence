package pf::SNMP::Cisco::Catalyst_4500;

=head1 NAME

pf::SNMP::Cisco::Catalyst_4500 - Object oriented module to access and configure Cisco Catalyst 4500 switches

=head1 STATUS

This module is currently only a placeholder, see pf::SNMP::Cisco::Catalyst_2960.

We do not know the minimum required firmware version.

=head1 BUGS AND LIMITATIONS

Because a lot of code is shared with the 2960 make sure to check the BUGS AND LIMITATIONS section of 
L<pf::SNMP::Cisco::Catalyst_2960> also.

=head1 CONFIGURATION AND ENVIRONMENT

F<conf/switches.conf>

=cut

use strict;
use warnings;
use Log::Log4perl;
use Net::SNMP;

use base ('pf::SNMP::Cisco::Catalyst_2960');

=head1 AUTHOR

Olivier Bilodeau <obilodeau@inverse.ca>

Regis Balzard <rbalzard@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2010,2011 Inverse inc.

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

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
