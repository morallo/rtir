# {{{ BEGIN BPS TAGGED BLOCK
# 
# COPYRIGHT:
#  
# This software is Copyright (c) 1996-2004 Best Practical Solutions, LLC 
#                                          <jesse@bestpractical.com>
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
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
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
# }}} END BPS TAGGED BLOCK
#
package RT::IR;

use Business::Hours;
use Business::SLA;

sub BusinessHours {

    my $bizhours = new Business::Hours;
    if ($RT::BusinessHours) {
	$bizhours->business_hours(%$RT::BusinessHours);
    }

    return $bizhours;
}

sub DefaultSLA {

    my $sla;
    my $SLAObj = SLAInit();
    $sla = $SLAObj->SLA(time());

    return $sla;

}

sub SLAInit {

    my $class = $RT::SLAModule || 'Business::SLA';

    my $SLAObj = $class->new();

    my $bh = RT::IR::BusinessHours();
    $SLAObj->SetInHoursDefault($RT::_RTIR_SLA_inhours_default);
    $SLAObj->SetOutOfHoursDefault($RT::_RTIR_SLA_outofhours_default);

    $SLAObj->SetBusinessHours($bh);

    foreach my $key (keys %$RT::SLA) {
	$SLAObj->Add($key, ( BusinessMinutes =>  $RT::SLA->{$key} ));
    }

    return $SLAObj;

}

1;
