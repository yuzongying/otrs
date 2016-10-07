#!/usr/bin/perl
# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel/cpan-lib';
use lib dirname($RealBin) . '/Custom';

use Getopt::Std;

use Kernel::System::ObjectManager;

# get options
my %Opts;
getopt( '', \%Opts );
if ( $Opts{h} ) {
    print "otrs.CleanTicketIndex.pl - clean static index\n";
    print "Copyright (C) 2001-2016 OTRS AG, http://otrs.com/\n";
    print "usage: otrs.CleanTicketIndex.pl\n";
    exit 1;
}

# create object manager
local $Kernel::OM = Kernel::System::ObjectManager->new(
    'Kernel::System::Log' => {
        LogPrefix => 'otrs.CleanTicketIndex.pl',
    },
);

my $Module = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::IndexModule');

print "Module is $Module\n";

if ( $Module !~ /StaticDB/ ) {
    print "You are using $Module as index, you should not clean it.\n";
    exit 0;
}

print "OTRS is configured to use $Module as index\n";

# get database object
my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

$DBObject->Prepare(
    SQL => 'SELECT count(*) from ticket_index'
);

while ( my @Row = $DBObject->FetchrowArray() ) {

    if ( $Row[0] ) {

        print "Found $Row[0] records in StaticDB index.\n";
        print "Deleting $Row[0] records...";

        $DBObject->Do(
            SQL => 'DELETE FROM ticket_index',
        );

        print " OK!\n";
    }
    else {
        print "No records found in StaticDB index.. OK!\n";
    }
}

$DBObject->Prepare(
    SQL => 'SELECT count(*) from ticket_lock_index',
);

while ( my @Row = $DBObject->FetchrowArray() ) {

    if ( $Row[0] ) {

        print "Found $Row[0] records in StaticDB lock_index.\n";
        print "Deleting $Row[0] records...";

        $DBObject->Do(
            SQL => 'DELETE FROM ticket_lock_index',
        );

        print " OK!\n";
    }
    else {
        print "No records found in StaticDB lock_index.. OK!\n";
    }
}

exit 0;
