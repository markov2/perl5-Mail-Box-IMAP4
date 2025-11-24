#oodist: *** DO NOT USE THIS VERSION FOR PRODUCTION ***
#oodist: This file contains OODoc-style documentation which will get stripped
#oodist: during its release in the distribution.  You can use this file for
#oodist: testing, however the code of this development version may be broken!

package Mail::Box::IMAP4s;
use parent 'Mail::Box::IMAP4';

use strict;
use warnings;

use Log::Report     'mail-box-imap4';

use IO::Socket::SSL qw/SSL_VERIFY_NONE/;

#--------------------
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

See Mail::Box::IMAP4.

=chapter METHODS

=c_method new %options
=default server_port  993

=option starttls BOOLEAN
=default starttls false

=option  ssl HASH|ARRAY
=default ssl { SSL_verify_mode => SSL_VERIFY_NONE }
Parameters to initialize the SSL connection.

=cut

sub init($)
{	my ($self, $args) = @_;
	$args->{server_port} = 993;
	$args->{starttls}    = 0;
	$self->SUPER::init($args);
}

sub type() {'imap4s'}

sub createTransporter($@)
{	my ($self, $class, %args) = @_;
	$args{starttls} = 0;
	$args{ssl} ||= +{ SSL_verify_mode => SSL_VERIFY_NONE };
	$self->SUPER::createTransporter($class, %args);
}

1;
