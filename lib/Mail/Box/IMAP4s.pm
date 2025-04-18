# This code is part of distribution Mail-Box-IMAP4.  Meta-POD processed with
# OODoc into POD and HTML manual-pages.  See README.md
# Copyright Mark Overmeer.  Licensed under the same terms as Perl itself.

package Mail::Box::IMAP4s;
use base 'Mail::Box::IMAP4';

use strict;
use warnings;

use IO::Socket::IP;
use IO::Socket::SSL qw(SSL_VERIFY_NONE);

=chapter NAME

Mail::Box::IMAP4s - handle IMAP4 folders as client, with ssl connection

=chapter SYNOPSIS

 my $url = 'imap4s://user:passwd@host:port/INBOX';
 my $url = 'imaps://user:passwd@host:port/INBOX';

 use Mail::Box::IMAP4s;
 my $folder = Mail::Box::IMAP4s->new(folder => $url, ...);

 my $mgr    = Mail::Box::Manager->new;
 my $folder = $msg->open($url, retry => 3, interval => 5);

=chapter DESCRIPTION

See M<Mail::Box::IMAP4>.

=chapter METHODS

=c_method new %options
=default server_port  993

=option starttls BOOLEAN
=default starttls C<false>

=option  ssl HASH|ARRAY
=default ssl { SSL_verify_mode => SSL_VERIFY_NONE }
Parameters to initialize the SSL connection.

=cut

sub init($)
{   my ($self, $args) = @_;
    $args->{server_port} = 993;
	$args->{starttls}    = 0;
    $self->SUPER::init($args);
}

sub type() {'imap4s'}


sub createTransporter($@)
{   my ($self, $class, %args) = @_;
    $args{starttls} = 0;
    $args{ssl} ||= { SSL_verify_mode => SSL_VERIFY_NONE };
    $self->SUPER::createTransporter($class, %args);
}

1;
