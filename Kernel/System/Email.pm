# --
# Kernel/System/Email.pm - the global email send module
# Copyright (C) 2001-2004 Martin Edenhofer <martin+code@otrs.org>
# --
# $Id: Email.pm,v 1.3 2004-01-10 12:48:22 martin Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

package Kernel::System::Email;

use strict;

use vars qw($VERSION);
$VERSION = '$Revision: 1.3 $';
$VERSION =~ s/^\$.*:\W(.*)\W.+?$/$1/;

=head1 NAME

Kernel::System::Email - to send email

=head1 SYNOPSIS

Global module to send email via sendmail or SMTP.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create a object 
 
  use Kernel::Config;
  use Kernel::System::Log;
  use Kernel::System::DB;

  my $ConfigObject = Kernel::Config->new();
  my $LogObject    = Kernel::System::Log->new(
      ConfigObject => $ConfigObject,
  );
  my $DBObject = Kernel::System::DB->new( 
      ConfigObject => $ConfigObject,
      LogObject => $LogObject,
  );
  my $SendObject = Kernel::System::Email->new(
      ConfigObject => $ConfigObject,
      LogObject => $LogObject,
      DBObject => $DBObject,
  );

=cut

# --
sub new {
    my $Type = shift;
    my %Param = @_;
    # allocate new hash for object
    my $Self = {}; 
    bless ($Self, $Type);
    # get common opjects
    foreach (keys %Param) {
        $Self->{$_} = $Param{$_};
    }
    # debug level
    $Param{Debug} = 0;
    # check all needed objects
    foreach (qw(ConfigObject LogObject DBObject)) {
        die "Got no $_" if (!$Self->{$_});
    }
    # load generator backend module
    my $GenericModule = $Self->{ConfigObject}->Get('SendmailModule')
      || 'Kernel::System::Email::Sendmail';
    if (!eval "require $GenericModule") {
        die "Can't load sendmail backend module $GenericModule! $@";
    }
    # create backend object
    $Self->{Backend} = $GenericModule->new(%Param);

    return $Self;
}
# --

=item Send()

To send an email.

    if ($SendObject->Send(
      From => 'me@example.com', 
      To => 'friend@example.com', 
      Subject => 'Some words!',
      Body => 'Some nice text',)) {
        print "Email sent!\n";
    }
    else {
        print "Email not sent!\n";
    }

=cut

sub Send {
    my $Self = shift;
    my %Param = @_;
    return $Self->{Backend}->Send(%Param);
}
# --
1;

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).  

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see http://www.gnu.org/licenses/gpl.txt.

=cut

=head1 VERSION

$Revision: 1.3 $ $Date: 2004-01-10 12:48:22 $

=cut

