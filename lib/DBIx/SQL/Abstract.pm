# $DBIx::SQL::Abstract.pm,v 1.1 2005/09/06  14:15:53 alex Exp $
#
# Copyright (c) 2004 Alejandro Juarez <alex@bsdcoders.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#                                                                             
# PURPOSE: This module was created to serve several functions inhereted from  
#          the DBIx and SQL::Abstract modules ...                              
#                                                                             
# USAGE: To read the HOW TO USE instructions you need to run perldoc:         
#                                                                             
#        perldoc DBIx::SQL::Abstract                                           
#

package DBIx::SQL::Abstract;
use strict;
use warnings;
use Carp;
use base 'DBIx';
use SQL::Abstract;
use DBI;
use vars qw(@ISA);
require Exporter;
@ISA = qw(DBI DBI::db DBI::st SQL::Abstract);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
# This allows declaration	use DBIx::SQL::Abstract ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw( insert ) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( );

our $VERSION = '0.01';

sub new {
    my ($class, %params) = @_;
    # Setting the DBIx and database default parameters
    my $dbi = { PrintError => 1,
		RaiseError => 0,
		AutoCommit => 0,
		ChopBlanks => 1
		      };

    my $db = { driver => 'Pg',
	       dbname => 'db',
	       host => undef,
	       port => undef,
	       user => 'user',
	       passwd => undef
	       };

    # Checking for wrong params...
    # if you don't give us any arguments we'll use the default params
    my $params_ok = 0;
    my ($dbLine, @dbargs);
    if ( scalar @_ == 1 ) {
	$dbLine = "dbi:$db->{dbd}:dbname='$db->{dbname}'";
	push @dbargs, $dbLine, $db->{dbuser}, $db->{dbpasswd};
	$params_ok = 1;
    } elsif (scalar @_ % 2) { 
	# Checking if the parameter list is a hash with the form: 
	# param => value";
	my @wrongkeys;
	for my $key (keys %params) {
	    if (exists $dbi->{$key} && defined $params{$key} ) {
		$dbi->{$key} = $params{$key}; 
	    } elsif (exists $db->{$key} ) {
		$db->{$key} = $params{$key};
	    } else {
		push @wrongkeys, $key;
	    }
	}
	if ( $#wrongkeys < 0 ) {
	    $dbLine = "dbi:$db->{dbd}:dbname='$db->{dbname}'";
	    push @dbargs, $dbLine, $db->{dbuser}, $db->{dbpasswd};
	    $params_ok = 1;
	} else {
	    carp 'DB: The next options were found wrong: '
		. join (', ', @wrongkeys)  . "\n";
	}
	
    } else {
	return undef;
    }
    
    # Opening the database connection and returning the dbh object builded
    if ( $params_ok ) {

	my $dbh = DBI->connect(@dbargs, \%$dbi) or
 	    die ("Failed to open database connection:\n", $DBI::errstr) &&
	    return undef;

	return bless $dbh, $class;
    }
}


sub DESTROY {
    # If we are not in autocommit mode, roll back any transactions left
    # pending. Cleanly disconnect from the database before disappearing.
    my $self = shift;
    if (ref $self ) {
	if ($self->{AutoCommit} == 1 ) {
	    $self->commit;
	} else {
	    $self->rollback;
	}
    }
}


1;
__END__


=head1 NAME

DBIx::SQL::Abstract -  Provides a convenient abstraction layer to a database.

=head1 SYNOPSIS

  use DBIx::SQL::Abstract;

  my $dbh = DBIx::SQL::Abstract->new( %dbcfg );

  Building SQL Abstractions.

  my($query, @bind) = $dbh->select($table, \@fields, \%where, \@order);
  my($query, @bind) = $dbh->insert($table, \%fieldvals || \@values);
  my($query, @bind) = $dbh->update($table, \%fieldvals, \%where);
  my($query, @bind) = $dbh->delete($table, \%where);

  Using DBI methods

  my $sth = $dbh->prepare($query);
  $sth->execute(@bind_params);
  ...
  my $rc  = $dbh->begin_work;
  my $rc  = $dbh->commit;
  my $rc  = $dbh->rollback;
  my $rc  = $dbh->disconnect;

  Anything else DBI method can be used, by Example:

  my $err = $dbh->err;
  my $err = $dbh->errstr;
  my $rv  = $dbh->state;
  my $rc  = $dbh->DESTROY;


=head1 DESCRIPTION

The intention of this module is to join some methods from the
DBI and the SQL::Abstract modules, for a convenient and easy use.

To begin, we create an object, but first we must create a hash which
contains the database parameters as follows.

    my %dbcfg = { PrintError => 1,
                  RaiseError => 0,
                  AutoCommit => 0,
                  ChopBlanks => 1 
                  driver => 'Pg',
                  dbname => 'db',
                  host => undef,
                  port => undef,
                  user => 'user',
                  passwd => undef
                };

Notice that this parameters are set as default unless you set your
required values.

my $dbh = DBIx::SQL::Abstract->new( %dbcfg );

This object automatically creates the connection with the database, and gets
the methods listed above. 

=head2 EXPORT

None by default.

=head1 SEE ALSO

You may want to check out the DBI and the SQL::Abstract documentation.
If you're interested in getting a better knowledge of its methods, 
please check it out. 

See L<SQL::Abstract> and L<DBI>.

    perldoc SQL::Abstract
    perldoc DBI

=head1 AUTHOR

Alejandro Juarez, E<lt>alex@bsdcoders.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Alejandro Juarez

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

=cut

