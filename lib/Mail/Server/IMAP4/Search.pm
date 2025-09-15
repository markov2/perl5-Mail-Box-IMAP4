#oodist: *** DO NOT USE THIS VERSION FOR PRODUCTION ***
#oodist: This file contains OODoc-style documentation which will get stripped
#oodist: during its release in the distribution.  You can use this file for
#oodist: testing, however the code of this development version may be broken!

package Mail::Server::IMAP4::Search;
use base 'Mail::Box::Search';

use strict;
use warnings;

#--------------------
=chapter NAME

Mail::Server::IMAP4::Search - select messages within a IMAP folder (not completed)

=chapter SYNOPSIS

  use Mail::Box::Manager;
  my $mgr    = Mail::Box::Manager->new;
  my $folder = $mgr->open('imap4:Inbox');

  my $filter = Mail::Server::IMAP4::Search->new(...);

  my @msgs   = $filter->search($folder);
  if($filter->search($message)) {...}

=chapter DESCRIPTION

THIS PACKAGES IS NOT IMPLEMENTED YET...  (it's waiting for a volunteer)

=chapter METHODS

=c_method new %options

=cut

sub init($)
{	my ($self, $args) = @_;
	$self->notImplemented;
}

1;
