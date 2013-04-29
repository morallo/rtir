# BEGIN BPS TAGGED BLOCK {{{
#
# COPYRIGHT:
#
# This software is Copyright (c) 1996-2013 Best Practical Solutions, LLC
#                                          <sales@bestpractical.com>
#
# (Except where explicitly superseded by other copyright notices)
#
#
# LICENSE:
#
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org.
#
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.html.
#
#
# CONTRIBUTION SUBMISSION POLICY:
#
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to Best Practical Solutions, LLC.)
#
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# Request Tracker, to Best Practical Solutions, LLC, you confirm that
# you are the copyright holder for those contributions and you grant
# Best Practical Solutions,  LLC a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
#
# END BPS TAGGED BLOCK }}}

use strict;
use warnings;

package RT::Condition::RTIR;
use base 'RT::Condition';

=head1 NAME

RT::Condition::RTIR - generic checks

=head1 METHODS

=head2 IsStaff

Returns true if creator of a transaction is a staff member. By staff member
we mean member of a group which name contains 'DutyTeam'.

=cut

sub IsStaff {
    my $self = shift;

    my $actor_id = $self->TransactionObj->Creator;
    my $cgm = RT::CachedGroupMembers->new( RT->SystemUser );
    $cgm->Limit(FIELD => 'MemberId', VALUE => $actor_id );
    my $group_alias = $cgm->Join(
        FIELD1 => 'GroupId', TABLE2 => 'Groups', FIELD2 => 'id'
    );
    $cgm->Limit(
        ALIAS    => $group_alias,
        FIELD    => 'Name',
        OPERATOR => 'LIKE',
        VALUE    => 'DutyTeam',
    );
    $cgm->RowsPerPage(1);
    return $cgm->First? 1 : 0;
}

RT::Base->_ImportOverlays;

1;
