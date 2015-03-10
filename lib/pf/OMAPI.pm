package pf::OMAPI;
=head1 NAME

pf::OMAPI add documentation

=cut

=head1 DESCRIPTION

pf::OMAPI

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use pf::OMAPI;

    my $omapi = pf::OMAPI->new( keyname => 'defomapi',key_base64 => 'xJviCHiQKcDu6hk7+Ffa3A==', host => 'localhost', port => 7911);

    my $data = $omapi->lookup({'ip-address' => "10.229.25.247" });

=cut

use strict;
use warnings;
use Moo;
use MIME::Base64;
use Net::IP;
use Digest::HMAC_MD5 qw(hmac_md5);
use IO::Socket::INET;
use Socket qw(MSG_WAITALL);

our $VERSION = '0.01';


=head1 ATTRIBUTES

=head2 host

host of dhcp server

=cut

has host => (is => 'rw', default => 'localhost');

=head2 port

port of the dhcp server

=cut

has port => (is => 'rw', default => 7911);

=head2 buffer

The reference to the buffer of message

=cut

has buffer => (is => 'rw', default => sub { my $s = "";\$s } );

=head2 sock



=cut

has sock => (is => 'rw', builder => 1, lazy => 1, clearer => 1);

has connected => (is => 'rw' , default => 0 );

has keyname => (is => 'rw');

has op => (is => 'rw');

has msg => (is => 'rw');

has obj => (is => 'rw');

has authid => (is => 'rw', default => 0);

has authlen => (is => 'rw', default => 0);

=head2 id

The current id of the message

=cut

has id => (is => 'rw', default=> sub { int(rand(0x10000000)) } );

has key => (is => 'rw', builder => 1, lazy => 1);

has key_base64 => (is => 'rw');

our $OPEN    = 1;
our $REFRESH = 2;
our $UPDATE  = 3;
our $NOTIFY  = 4;
our $ERROR   = 5;
our $DELETE  = 6;


our %FORMATLIST = (
    'flags'                  => 'C',
    'ends'                   => 'N',
    'tstp'                   => 'N',
    'tsfp'                   => 'N',
    'cltt'                   => 'N',
    'pool'                   => 'N',
    'state'                  => 'N',
    'atsfp'                  => 'N',
    'starts'                 => 'N',
    'subnet'                 => 'N',
    'hardware-type'          => 'N',
    'result'          => 'N',
);


our %UNPACK_DATA = (
    'ip-address' => , \&unpack_ip_address,
    'hardware-address' =>,\&unpack_hardware_address,
);

our %PACK_DATA = (
    'ip-address' => , \&pack_ip_address,
    'hardware-address' =>,\&pack_hardware_address,
);


=head1 SUBROUTINES/METHODS

=head2 _trigger_key_base64

The will set the key to the binary from the base 64 version of the key

=cut

sub _trigger_key_base64 {
    my ($self) = @_;
    $self->key(decode_base64($self->key_base64));
}

=head2 _build_key 

=cut

sub _build_key {
    my ($self) = @_;
    return decode_base64($self->key_base64);
}


=head2 connect

Will connect and authenticate to the omapi server

=cut

sub connect {
    my ($self) = @_;
    return 1 if $self->connected;
    my ($recieved_startup_message,$len);
    my $sock = $self->sock;
    $len = $sock->read($recieved_startup_message,8);
    my ($version,$headerLength) = unpack('N2',$recieved_startup_message);
    my $startup_message = pack("N2",$version,$headerLength);
    $len = $sock->send($startup_message) || die "error sending startup message";

    unless ($self->send_auth()) {
        $self->connected(0);
        $sock->close();
        $self->clear_sock();
        die "Error send auth";
    }
    $self->connected(1);
    return 1;
}


=head2 send_auth

send the auto info

=cut

sub send_auth {
    my ($self) = @_;
    #no key if the we are good to go
    return 1 unless $self->key && $self->keyname;
    my $reply = $self->send_msg($OPEN,{type => 'authenticator'},{ name => $self->keyname, algorithm => 'hmac-md5.SIG-ALG.REG.INT.'});
    return 0 unless $reply->{op} == $UPDATE;

    $self->authid ($reply->{handle});
    $self->authlen(16);
    return 1;
}

sub lookup {
    my ($self, $msg, $obj) = @_;
    $self->connect();
    return $self->send_msg($OPEN,$msg, $obj);
}

sub send_msg {
    my ($self, $op, $msg, $obj) = @_;
    $self->op($op);
    $self->msg($msg);
    $self->obj($obj);
    $self->send();
    return $self->get_reply();
}

=head2 send

send the message

=cut

sub send {
    my ($self) = @_;
    $self->_build_message;
    return $self->sock->send(${$self->buffer});
}

=head2 get_reply

get the reply of the message

=cut

sub get_reply {
    my ($self) = @_;
    my $data;
    $self->sock->recv($data,64*1024);
    return $self->parse_stream($data) ;
}

sub _build_message {
    my ($self) = @_;
    $self->_clear_buffer;
    my $handle = 0;
    $self->_append_ints_buffer($self->authid,$self->authlen,$self->op,0,$self->id,0);
    $self->_append_name_values($self->msg);
    $self->_append_name_values($self->obj);
    $self->_sign();
}

=head2 _append_name_values

TODO: documention

=cut

sub _append_name_values {
    my ($self,$data) = @_;
     while( my ($name,$value) = each %$data) {
        if(exists $FORMATLIST{$name} ) {
            $value = pack($FORMATLIST{$name},$value);
        }
        if(exists $PACK_DATA{$name}) {
            $value = $PACK_DATA{$name}->($self,$value);
        }
        $self->_pack_and_append('n/a* N/a*',$name,$value);
    }
    $self->_pack_and_append('n',0);
    return ;
}

sub _build_sock {
    my ($self) = @_;
    my $sock = IO::Socket::INET->new(PeerAddr => $self->host, PeerPort => $self->port, Proto => 'tcp') || die "Can't bind : $@\n";
    return $sock;
}

sub _clear_buffer {
    my ($self) = @_;
    my $buf = $self->buffer;
    $$buf = '';
}

sub _append_ints_buffer {
    my ($self,@ints) = @_;
    $self->_pack_and_append('N*',@ints);
}

sub _pack_and_append {
    my ($self,$format,@data) = @_;
    my $data = pack($format,@data); 
    my $buf = $self->buffer;
    $$buf .= $data;
}


=head2 parse_stream

=cut

sub parse_stream {
    my ($self, $buffer) = @_;
    my ($msg,$obj,$sig);
    my ($authid, $authlen, $op, $handle, $id, $rid, $rest) = unpack('N6 a*',$buffer);
    if($rest && length($rest)) {
        ($msg, $rest) = $self->parse_name_value_pairs($rest);
        ($obj, $rest) = $self->parse_name_value_pairs($rest);
        $sig = unpack("a$authlen",$rest);
    }
    return {
        op      => $op,
        id      => $id,
        rid     => $rid,
        handle  => $handle,
        authlen => $authlen,
        authid  => $authid,
        msg     => $msg,
        obj     => $obj,
        sig     => $sig,
    };
}


=head2 parse_name_value


=cut

sub parse_name_value_pairs {
    my ($self,$rest) = @_;
    my %data;
    my ($value,$name);
    ($name,$rest) = unpack('n/a a*',$rest); 
    while($name) {
        ($value,$rest) = unpack('N/a a*',$rest); 
        if(exists $FORMATLIST{$name}) {
            $value = unpack($FORMATLIST{$name},$value);
        }
        if(exists $UNPACK_DATA{$name} ) {
            $value = $UNPACK_DATA{$name}->($self,$value);
        }
        $data{$name} = $value;
        
        ($name,$rest) = unpack('n/a a*',$rest); 
    }
    return (\%data,$rest);
}

sub pack_ip_address {
    my ($self,$value) = @_;
    $value = pack("C4",split('\.',$value));
    return $value;
}

sub pack_hardware_address {
    my ($self,$value) = @_;
    return pack("C6",split(':',$value));
}

sub unpack_ip_address {
    my ($self,$value) = @_;
    return join('.',unpack("C4",$value));
}

sub unpack_hardware_address {
    my ($self,$value) = @_;
    return join(':',map { sprintf "%x", $_ } unpack("C6",$value));
}

sub _sign {
    my ($self) = @_;
    return unless $self->authid;
    my $buffer = $self->buffer;
    my $digest = hmac_md5(substr($$buffer,4), $self->key);
    $$buffer .= $digest;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2014 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and::or
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
