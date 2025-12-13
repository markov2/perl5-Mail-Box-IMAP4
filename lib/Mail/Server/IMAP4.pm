#oodist: *** DO NOT USE THIS VERSION FOR PRODUCTION ***
#oodist: This file contains OODoc-style documentation which will get stripped
#oodist: during its release in the distribution.  You can use this file for
#oodist: testing, however the code of this development version may be broken!

package Mail::Server::IMAP4;
use parent 'Mail::Server';

use strict;
use warnings;

use Log::Report 'mail-box-imap4', import => [];

use Mail::Server::IMAP4::List   ();
use Mail::Server::IMAP4::Fetch  ();
use Mail::Server::IMAP4::Search ();
use Mail::Transport::IMAP4      ();

#--------------------
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
=item * Mail::Server::IMAP4::Fetch
used to capture "FETCH" related information from a message, and produce
server-side FETCH answers.

=item * Mail::Server::IMAP4::List
produce LIST responses about existing folders.  This works
in combination with a Mail::Box::Manage::User object.

=item * Mail::Server::IMAP4::Search
the SEARCH request.  Not implemented yet... looking for a volunteer.
=back

=chapter METHODS
=cut

#--------------------
=chapter DETAILS

See
=over 4
=item RFC2060: "Internet Message Access Protocol IMAP4v1"
=back

=cut

1;
