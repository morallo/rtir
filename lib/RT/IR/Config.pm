# BEGIN BPS TAGGED BLOCK {{{
#
# COPYRIGHT:
#
# This software is Copyright (c) 1996-2014 Best Practical Solutions, LLC
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

package RT::IR::Config;
use strict;
use warnings;

sub Init {
    use RT::Config;
    my %meta = (
        DisplayAfterEdit => {
            Section         => 'Tickets view',
            Overridable     => 1,
            Widget          => '/Widgets/Form/Boolean',
            WidgetArguments => {
                Description => 'Display ticket after edit (don\'t stay on the edit page)',
            },
        },
    );
    %RT::Config::META = (%meta, %RT::Config::META);

    # Tack on the PostLoadCheck here so it runs no matter where
    # RTIRSearchResultFormats gets loaded from. It will still
    # squash any other PostLoadChecks for this config entry, but those
    # should go here.
    $RT::Config::META{RTIRSearchResultFormats}{PostLoadCheck} =
        sub {
            my ($self, $value) = @_;
            foreach my $format ( keys %{$value} ){
                CheckObsoleteCFSyntax($value->{$format},
                    $RT::Config::META{RTIRSearchResultFormats}{Source}{File});
            }
        };

    return;
}

=head1 CheckObsoleteCFSyntax

RTIR upgrades changed the naming of installed custom fields,
removing the _RTIR_ prefix from the custom field names and removing
State in favor of RT's default Status.

This function checks queries and formats for references to the old
CF names and warns that they need to be updated.

Takes: $string, $location

String that can be a format or query that might have an old CF format.

Location is where the format or query is, if available.

Returns: Nothing, just issues a warning in the logs.

=cut

sub CheckObsoleteCFSyntax {
    my $string = shift;
    my $location = shift;
    return unless $string;

    $location = 'unknown' unless $location;

    if ( $string =~ /__CustomField\.\{State\}__/
         or $string =~ /CF\.\{State\}/ ){

        RT::Logger->warning('The custom field State has been replaced with the RT Status field.'
                        . ' You should update your custom searches and result formats accordingly.'
                        . ' See the UPGRADING file and the $RTIRSearchResultFormats option'
                        . ' in the default RTIR_Config.pm file. Found in: ' . $string
                        . ' from ' . $location );
    }

    if ( $string =~ /__CustomField\.\{_RTIR_(\w+)\}__/
         or $string =~ /CF\.\{_RTIR_\w+\}/ ){

        RT::Logger->warning('The _RTIR_ prefix has been removed from all RTIR custom fields.'
                        . ' You should update your custom searches and result formats accordingly.'
                        . ' See the UPGRADING file for details. Found in: ' . $string
                        . ' from ' . $location );
    }
    return;
}

1;
