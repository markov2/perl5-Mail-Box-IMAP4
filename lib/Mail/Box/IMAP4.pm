#oodist: *** DO NOT USE THIS VERSION FOR PRODUCTION ***
#oodist: This file contains OODoc-style documentation which will get stripped
#oodist: during its release in the distribution.  You can use this file for
#oodist: testing, however the code of this development version may be broken!

package Mail::Box::IMAP4;
use base 'Mail::Box::Net';

use strict;
use warnings;

use Log::Report 'mail-box-imap4', import => [ qw/__x error notice trace warning/ ];

use Mail::Box::IMAP4::Head        ();
use Mail::Box::IMAP4::Message     ();
use Mail::Box::Parser::Perl       ();
use Mail::Message::Head::Complete ();
use Mail::Message::Head::Delayed  ();
use Mail::Transport::IMAP4        ();

use Scalar::Util   qw/weaken blessed/;

#--------------------
=chapter NAME

Mail::Box::IMAP4 - handle IMAP4 folders as client

=chapter SYNOPSIS

  my $url = 'imap4://user:passwd@host:port/INBOX';
  my $url = 'imap://user:passwd@host:port/INBOX';

  use Mail::Box::IMAP4;
  my $folder = Mail::Box::IMAP4->new(folder => $url, ...);

  use Mail::Box::Manager;
  my $mgr    = Mail::Box::Manager->new;
  my $folder = $msg->open($url, retry => 3, interval => 5);

=chapter DESCRIPTION

Maintain a folder which has its messages stored on a remote server.  The
communication between the client application and the server is implemented
using the IMAP4 protocol.  See also Mail::Server::IMAP4.

B<Be aware:>
This module versions 4.0 and up is not fully compatible with older releases:
mainly the exception handling has changed.  When you need to upgrade, please
read F<https://github.com/markov2/perl5-Mail-Box/wiki/>
B<Version 3 is still maintained> and may see new releases as well.

This class uses Mail::Transport::IMAP4 to hide the transport of
information, and focusses solely on the correct handling of messages
within a IMAP4 folder.  More than one IMAP4 folder can be handled by
one single IMAP4 connection.

=chapter METHODS

=c_method new %options
The C<new> can have many %options.  Not only the ones listed here below,
but also all the %options for M<Mail::Transport::IMAP4::new()> can be
passed.

=default access 'r'

=default head_type Mail::Box::IMAP4::Head or Mail::Message::Head::Complete
The default depends on the value of M<new(cache_head)>.

=default folder C</>
Without folder name, no folder is selected.  Only few methods are
available now, for instance M<listSubFolders()> to get the top-level
folder names.  Usually, the folder named C<INBOX> will be present.

=default server_port  143
=default message_type Mail::Box::IMAP4::Message

=option  transporter  $object|$class
=default transporter  Mail::Transport::IMAP4
The name of the $class which will interface with the connection.  When you
implement your own extension to Mail::Transport::IMAP4, you can either
specify a fully instantiated transporter $object, or the name of your own
$class.  When an $object is given, most other options will be ignored.

=option  join_connection BOOLEAN
=default join_connection true
Within this Mail::Box::IMAP4 class is registered which transporters are
already in use, i.e. which connections to the IMAP server are already
in established.  When this option is set, multiple folder openings on the
same server will try to reuse one connection.

=option  cache_labels 'NO'|'WRITE'|'DELAY'
=default cache_labels C<NO> or C<DELAY>
When labels from a message are received, these values can be kept. However,
this imposes dangers where the server's internal label storage may get out
of sync with your data.

With C<NO>, no caching will take place (but the performance will be
worse). With C<WRITE>, all label access will be cached, but written to
the server as well.  Both C<NO> and C<WRITE> will update the labels on
the served, even when the folder was opened read-only.  C<DELAY> will
not write the changed information to the server, but delay that till
the moment that the folder is closed.  It only works when the folder is
opened read/write or write is enforced.

The default is C<DELAY> for folders which where opened read-only.  This
means that you still can force an update with M<close(write)>.  For folders
which are opened read-write, the default is the safeset setting, which is
C<NO>.

=option  cache_head 'NO'|'PARTIAL'|'DELAY'
=default cache_head C<NO> or C<DELAY>
For a read-only folder, C<DELAY> is the default, otherwise C<NO> is
chosen.  The four configuration parameter have subtile consequences.
To start with a table:

  [local cache]  [write]  [default head_type]
 NO         no           no     Mail::Box::IMAP4::Head
 PARTIAL    yes          no     Mail::Box::IMAP4::Head
 DELAY      yes          yes    Mail::Message::Head::Complete

The default P<head_type> is Mail::Box::IMAP4::Head, the
default C<cached_head_type> is Mail::Message::Head::Complete.

Having a local cache means that a lookup for a field is first done
in a local data-structure (which extends Mail::Message::Head::Partial),
and only on the remote server if it was not found.  This is dangerous,
because your locally cached data can be out-of-sync with the server.
However, it may give you a nice performance benefit.

C<DELAY> will always collect the whole
header for you.  This is required when you want to look for Resent Groups
(See Mail::Message::Head::ResentGroup) or other field order dependent
header access.  A Mail::Message::Head::Delayed will be created first.

=option  cache_body 'NO'|'YES'|'DELAY'
=default cache_body C<NO>
Body objects are immutable, but may still cached or not.  In common
case, the body of a message is requested via M<Mail::Message::body()>
or M<Mail::Message::decoded()>.  This returns a handle to a body object.
You may decide whether that body object can be reused or not.  C<NO>
means: retrieve the data each time again, C<YES> will cache the body data,
C<DELAY> will send the whole message when the folder is closed.

  [local cache]  [write]
 NO         no           no
 YES        yes          no
 DELAY      yes          yes

=examples
  my $imap   = Mail::Box::IMAP4->new(username => 'myname',
     password => 'mypassword', server_name => 'imap.xs4all.nl');

  my $url    = 'imap4://user:password@imap.xs4all.nl';
  my $imap   = $mgr->open($url);

  my $client = Mail::IMAPClient->new(...);
  my $imap   = Mail::Box::IMAP4->new(imap_client => $client);

=cut

sub init($)
{	my ($self, $args) = @_;
	my $folder = $args->{folder} // '/';

	# MailBox names top folder directory '=', but IMAP needs '/'
	$folder    = '/' if $folder eq '=';

	# There's a disconnect between the URL parser and this code.
	# The URL parser always produces a full path (beginning with /)
	# while this code expects to NOT get a full path.  So, we'll
	# trim the / from the front of the path.
	# Also, this code can't handle a trailing slash and there's
	# no reason to ever offer one.  Strip that too.
	if($folder ne '/')
	{	$folder =~ s,^/+,,g;
		$folder =~ s,/+$,,g;
	}

	$args->{folder} = $folder;

	my $access    = $args->{access} ||= 'r';
	my $writeable = $access =~ m/w|a/;
	my $ch        = $self->{MBI_c_head} = $args->{cache_head} || ($writeable ? 'NO' : 'DELAY');

	$args->{head_type}    ||= 'Mail::Box::IMAP4::Head'
		if $ch eq 'NO' || $ch eq 'PARTIAL';

	$args->{body_type}    ||= 'Mail::Message::Body::Lines';
	$args->{message_type} ||= 'Mail::Box::IMAP4::Message';

	if(my $client = $args->{imap_client}) {
		$args->{server_name} = $client->Socket->peerhost();
		$args->{server_port} = $client->Socket->peerport();
		$args->{username}    = $client->User;
	}

	$self->SUPER::init($args);

	$self->{MBI_domain}   = $args->{domain};
	$self->{MBI_c_labels} = $args->{cache_labels} || ($writeable ? 'NO' : 'DELAY');
	$self->{MBI_c_body}   = $args->{cache_body}   || ($writeable ? 'NO' : 'DELAY');

	my $transport = $args->{transporter} || 'Mail::Transport::IMAP4';
	blessed $transport or $transport = $self->createTransporter($transport, %$args);

	$self->transporter($transport);
	defined $transport or return;

	$args->{create} ? $self->create($transport, $args) : $self;
}

sub create($@)
{	my($self, $name, $args) =  @_;

	if($args->{access} !~ /w|a/)
	{	error __x"you must have write access to create folder {name}.", name => $name;
		return undef;
	}

	$self->transporter->createFolder($name);
}

sub foundIn(@)
{	my $self = shift;
	unshift @_, 'folder' if @_ % 2;
	my %args = @_;

	   (exists $args{type}   && $args{type}   =~ m/^imap/i)
	|| (exists $args{folder} && $args{folder} =~ m/^imap/);
}

sub type() {'imap4'}


=method close %options
Close the folder.  In the case of IMAP, more than one folder can use
the same connection, therefore, closing a folder does not always close
the connection to the server.  Only when no folder is using the
connection anymore, a logout will be invoked by
M<Mail::Transport::IMAP4::DESTROY()>
=cut

sub close(@)
{	my $self = shift;
	$self->SUPER::close(@_) or return ();
	$self->transporter(undef);
	$self;
}

sub listSubFolders(@)
{	my ($thing, %args) = @_;
	my $self = $thing;

	$self = $thing->new(%args) or return ()  # list toplevel
		unless ref $thing;

	my $imap = $self->transporter;
	defined $imap ? $imap->folders($self) : ();
}

sub nameOfSubfolder($;$) { $_[1] }

#--------------------
=section Internals

=cut

sub readMessages(@)
{	my ($self, %args) = @_;

	my $name  = $self->name;
	return $self if $name eq '/';

	my $imap  = $self->transporter // return;
	my $seqnr = 0;

	my $cl    = $self->{MBI_c_labels} ne 'NO';
	my $wl    = $self->{MBI_c_labels} ne 'DELAY';

	my $ch    = $self->{MBI_c_head};
	my $ht    = $ch eq 'DELAY' ? $args{head_delayed_type} : $args{head_type};
	my @ho    = $ch eq 'PARTIAL' ? (cache_fields => 1) : ();

	$self->{MBI_selectable}
		or return $self;

	foreach my $id ($imap->ids)
	{	my $head    = $ht->new(@ho);
		my $message = $args{message_type}->new(
			head      => $head,
			unique    => $id,
			folder    => $self,
			seqnr     => $seqnr++,

			cache_labels => $cl,
			write_labels => $wl,
			cache_head   => ($ch eq 'DELAY'),
			cache_body   => ($ch ne 'NO'),
		);

		my $body    = $args{body_delayed_type}->new(message => $message);
		$message->storeBody($body);
		$self->storeMessage($message);
	}

	$self;
}

=method getHead $message
Read the header for the specified message from the remote server.
undef is returned in case the message disappeared.

=warning message {id} disappeared from {folder}.
Trying to get the specific message from the server, but it appears to be gone.
=cut

sub getHead($)
{	my ($self, $message) = @_;
	my $imap   = $self->transporter or return;
	my $uidl   = $message->unique;
	my @fields = $imap->getFields($uidl, 'ALL');

	unless(@fields)
	{	warning __x"message {id} disappeared from {folder}.", id => $uidl, folder => "$self";
		return;
	}

	my $head = $self->{MB_head_type}->new;
	$head->addNoRealize($_) for @fields;

	trace "Loaded head of $uidl.";
	$head;
}


=method getHeadAndBody $message
Read all data for the specified message from the remote server.
Return head and body of the mesasge as list, or an empty list
if the $message disappeared from the server.

=warning message $id disappeared from $folder.
Trying to get the specific message from the server, but it appears to be
gone.

=warning cannot find head back for $id in $folder.
The header was read before, but now seems empty: the IMAP4 server does
not produce the header lines anymore.

=warning cannot read body for $id in $folder.
The header of the message was retrieved from the IMAP4 server, but the
body is not read, for an unknown reason.

=cut

sub getHeadAndBody($)
{	my ($self, $message) = @_;
	my $imap  = $self->transporter or return;
	my $uid   = $message->unique;
	my $lines = $imap->getMessageAsString($uid);

	unless(defined $lines)
	{	warning __x"message {id} disappeared from {folder}.", id => $uid, folder => $self->name;
		return ();
	}

	my $parser = Mail::Box::Parser::Perl->new(   # not parseable by C parser
		filename  => "$imap",
		file      => Mail::Box::FastScalar->new(\$lines)
	);

	my $head = $message->readHead($parser);
	unless(defined $head)
	{	warning __x"cannot find head back for {id} in {folder}.", id => $uid, folder => $self;
		$parser->stop;
		return ();
	}

	my $body = $message->readBody($parser, $head);
	unless(defined $body)
	{	warning __x"cannot read body for {id} in {folder}.", id => $uid, folder => $self->name;
		$parser->stop;
		return ();
	}

	$parser->stop;

	trace "loaded message $uid.";
	($head, $body->contentInfoFrom($head));
}


=method body [$body]
=cut

sub body(;$)
{	my $self = shift;
	@_ or return $self->{MBI_cache_body} ? $self->SUPER::body : undef;

	$self->unique();
	$self->SUPER::body(@_);
}


=method write %options
The IMAP protocol usually writes the data immediately to the remote server,
because that's what the protocol wants.  However, some options to M<new()>
may delay that to boost performance.  This method will, when the folder is
being closed, write that info after all.

=notice impossible to keep deleted messages in IMAP folder $name.
Some folder type have a 'deleted' flag which can be stored in the folder to
be performed later.  The folder keeps that knowledge even when the folder
is rewritten.  Well, IMAP4 cannot play that trick.

=cut

sub write(@)
{	my ($self, %args) = @_;
	my $imap  = $self->transporter or return;

	$self->SUPER::write(%args, transporter => $imap);

	if($args{save_deleted})
	{	notice __x"impossible to keep deleted messages in IMAP folder {name}.", name => $self->name;
	}
	else { $imap->destroyDeleted($self->name) }

	$self;
}

sub delete(@)
{	my $self   = shift;
	my $transp = $self->transporter;
	$self->SUPER::delete(@_);   # subfolders
	$transp->deleteFolder($self->name);
}


=method writeMessages %options
=requires transporter OBJECT
=cut

sub writeMessages($@)
{	my ($self, $args) = @_;

	my $imap = $args->{transporter};
	my $fn   = $self->name;

	$_->writeDelayed($fn, $imap) for @{$args->{messages}};

	$self;
}


=method createTransporter $class, %options
Create a transporter object (an instance of Mail::Transport::IMAP4), where
$class defines the exact object type.  As %options, everything which is
acceptable to a transporter initiation can be used (see
M<Mail::Transport::IMAP4::new()>.

=option  join_connection BOOLEAN
=default join_connection true
See M<new(join_connection)>.  When false, the connection will never be shared
with other IMAP mail boxes.

=cut

my %transporters;
sub createTransporter($@)
{	my ($self, $class, %args) = @_;

	my $hostname = $self->{MBN_hostname} || 'localhost';
	my $port     = $self->{MBN_port}     || '143';
	my $username = $self->{MBN_username} || $ENV{USER};

	my $join     = exists $args{join_connection} ? $args{join_connection} : 1;

	my $linkid;
	if($join)
	{	$linkid  = "$hostname:$port:$username";
		return $transporters{$linkid} if defined $transporters{$linkid};
	}

	my $transporter = $class->new(
		%args,
		hostname => $hostname, port     => $port,
		username => $username, password => $self->{MBN_password},
		domain   => $self->{MBI_domain},
	) or return undef;

	if(defined $linkid)
	{	$transporters{$linkid} = $transporter;
		weaken($transporters{$linkid});
	}

	$transporter;
}


=method transporter [$object]
Returns the object which is the interface to the IMAP4 protocol handler.
The IMAP4 handler has the current folder selected.
When an $object is specified, it is set to be the transporter from
that moment on.  The $object must extend Mail::Transport::IMAP4.

=error no IMAP4 transporter configured.
=error couldn't select IMAP4 folder $name.
=cut

sub transporter(;$)
{	my $self = shift;

	my $imap;
	if(@_)
	{	$imap = $self->{MBI_transport} = shift // return;
	}
	else
	{	$imap = $self->{MBI_transport};
	}

	defined $imap
		or error __x"no IMAP4 transporter configured.";

	my $name = $self->name;

	$self->{MBI_selectable} = $imap->currentFolder($name)
		or error "couldn't select IMAP4 folder {name}.", name => $name;

	$imap;
}


=method fetch <$messages|$selection>, $info
Low-level data retreival about one or more messages via IMAP4 from
the remote server. Some of this data may differ from the information
which is stored in the message objects which are created by MailBox,
so you should avoid the use of this method for your own purposes.
The IMAP implementation provides some wrappers around this, providing
the correct behavior.

An ARRAY of $messages may be specified or some message $selection,
acceptable to M<Mail::Box::messages()>.  Examples of the latter are
C<'ALL'>, C<'DELETED'>, or C<spam> (messages labelled to contain spam).

The $info contains one or more attributes as defined by the IMAP protocol.
You have to read the full specs of the related RFCs to see these.

=cut

sub fetch($@)
{	my ($self, $what, @info) = @_;
	my $imap = $self->transporter or return [];
	$what = $self->messages($what) unless ref $what eq 'ARRAY';
	$imap->fetch($what, @info);
}

#--------------------
=section Error handling

=chapter DETAILS

=section How IMAP4 folders work

=cut

1;
