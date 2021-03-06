# This code is part of distribution Mail-Box-IMAP4.  Meta-POD processed with
# OODoc into POD and HTML manual-pages.  See README.md
# Copyright Mark Overmeer.  Licensed under the same terms as Perl itself.

package Mail::Server::IMAP4::Search;
use base 'Mail::Box::Search';

use strict;
use warnings;

=chapter NAME

Mail::Server::IMAP4::Search - select messages within a IMAP folder (not completed)

=chapter SYNOPSIS

 use Mail::Box::Manager;
 my $mgr    = Mail::Box::Manager->new;
 my $folder = $mgr->open('imap4:Inbox');

 my $filter = Mail::Server::IMAP4::Search->new
    (  ...to be defined...
    );

 my @msgs   = $filter->search($folder);
 if($filter->search($message)) {...}

=chapter DESCRIPTION

THIS PACKAGES IS NOT IMPLEMENTED YET...  (it's waiting for a volunteer)

=chapter METHODS

=c_method new %options

=cut

sub init($)
{   my ($self, $args) = @_;
    $self->notImplemented;
}

#-------------------------------------------

1;
