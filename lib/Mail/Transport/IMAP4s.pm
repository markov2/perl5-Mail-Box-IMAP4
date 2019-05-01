# This code is part of distribution Mail-Box-IMAP4.  Meta-POD processed with
# OODoc into POD and HTML manual-pages.  See README.md
# Copyright Mark Overmeer.  Licensed under the same terms as Perl itself.

package Mail::Transport::IMAP4s;
use base 'Mail::Transport::IMAP4';

use strict;
use warnings;

=chapter NAME

Mail::Transport::IMAP4 - proxy to Mail::IMAPClient

=chapter SYNOPSIS

 my $imap = Mail::Transport::IMAP4s->new(...);
 my $message = $imap->receive($id);
 $imap->send($message);

=chapter DESCRIPTION

=chapter METHODS

=c_method new %options

=default port 993
=default ssl  <true>

=cut

sub init($)
{   my ($self, $args) = @_;
	$args->{ssl}  //= 1;
    $args->{port} //= 993;
    $self->SUPER::init($args) or return;
}

1;
