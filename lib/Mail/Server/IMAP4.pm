# This code is part of distribution Mail-Box-IMAP4.  Meta-POD processed with
# OODoc into POD and HTML manual-pages.  See README.md
# Copyright Mark Overmeer.  Licensed under the same terms as Perl itself.

package Mail::Server::IMAP4;
use base 'Mail::Server';

use strict;
use warnings;

use Mail::Server::IMAP4::List;
use Mail::Server::IMAP4::Fetch;
use Mail::Server::IMAP4::Search;
use Mail::Transport::IMAP4;

=chapter NAME

Mail::Server::IMAP4 - IMAP4 server implementation (not completed)

=chapter SYNOPSIS

 !!!Partially implemented!!!!
 my $server = Mail::Server::IMAP4->new($msg);

=chapter DESCRIPTION

This module is a place-holder, which can be used to grow code which
is needed to implement a full IMAP4 server.

Although the server is not implemented, parts of this server are
already available.

=over 4
=item * M<Mail::Server::IMAP4::Fetch>
used to capture "FETCH" related information from a message, and produce
server-side FETCH answers.

=item * M<Mail::Server::IMAP4::List>
produce LIST responses about existing folders.  This works
in combination with a M<Mail::Box::Manage::User> object.

=item * M<Mail::Server::IMAP4::Search>
the SEARCH request.  Not implemented yet... looking for a volunteer.
=back

=chapter METHODS

=cut

#-------------------------------------------

=chapter DETAILS

See
=over 4
=item RFC2060: "Internet Message Access Protocol IMAP4v1"
=back

=cut

1;
