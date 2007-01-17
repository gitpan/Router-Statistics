#!/usr/bin/perl

use strict;
use Router::Statistics;

# This script is an example of how to poll a UBR and then poll all
# the CPEs connected to it in one shot.

# Also it is a demonstration of how the CPE functions within the module work
# as many are not documented. One element which may be of most interest is the
# ability for multiple SNMP keys to be provided and the code with use them in 
# order until the correct one is found, or there are no more at which point
# the request CPE is removed from the list.

my ($ip)=$ARGV[0];
my ($key)=$ARGV[1];

unless (@ARGV==2)
        {
        my ($name)=($0 =~ /([^\/]+$)/);
       print "Usage: $name <ip> <key>\n";
        exit(0);
        }

my $test= new Router::Statistics( [DEBUG=>0] );
my ( %routers ,%interfaces, %profiles, %cpe_information);
my $result;

$result = $test->Router_Add( $ip , $key );
$result = $test->Router_Ready_Blocking ( $ip );
$result = $test->Router_Test_Connection_Blocking(\%routers);

if ( scalar( keys %routers )==0 )
        { print "No access to Any of the Routers specified.\n";exit(0); }

my $cpe_snmp_variables = Router::Statistics::OID->CPE_populate_oid();

$result = $test->UBR_get_active_cpe_profiles_Blocking( \%profiles );
$result = $test->Router_get_interfaces_Blocking( \%interfaces );
$result = $test->UBR_get_CPE_information_Blocking( \%cpe_information,"CPEIP" );

# before you can use a non-blocking object you need to remove all the blocking ones.
# I might add a 'router_cleanup' function so making it simplier.

$result = $test->Router_Remove_All();

my %cpe_data;
my $handler;
my %concat;

# This where all the CPEs are added into the CPE table.
# The multiple SNMP keys are provided as a comma seperated list along
# with the router and cpe reference IDs and a 1 second timeout.

foreach my $router ( keys %cpe_information )
        {
        foreach my $cpe ( keys %{$cpe_information{$router}} )
                {
                $result = $test->CPE_Add 
				( 
				$cpe_information{$router}{$cpe}{'docsIfCmtsCmStatusIpAddress'}, 
				"public,private,different", 
				$router, 
				$cpe, 
				1 
				);
                $result = $test->CPE_Ready ( $cpe_information{$router}{$cpe}{'docsIfCmtsCmStatusIpAddress'} );
                }
        }

# This is where all the CPEs are tested for the correct SNMP keys. If they are not
# correct they are removed from the CPE table.
my %testingme;
$result = $test->CPE_Test_Connection(\%testingme);


# Now we ready all the CPEs with the OIDs we are after.
foreach my $router ( keys %cpe_information )
        {
        foreach my $cpe ( keys %{$cpe_information{$router}} )
                {
                $result = $test->CPE_Ready ( $cpe_information{$router}{$cpe}{'docsIfCmtsCmStatusIpAddress'}
				,
                        [
                        ${$cpe_snmp_variables}{'sysDescr'},
                        ${$cpe_snmp_variables}{'docsDevSwCurrentVers'},
                        ${$cpe_snmp_variables}{'SoftwareVersion'},
                        ${$cpe_snmp_variables}{'DOCSISFileName'},
			${$cpe_snmp_variables}{'ifPhysAddress'}
                        ]
                        );
                }
        }
# We gather all the data.
$test->CPE_gather_all_data(\%cpe_data);

# Now we store it in a file called the router ip provided.
# One external reference needs resolving ( _GLOBAL is an internal ref )
# but works for now.

open (__OUTPUT,">$ip");
foreach my $cpe ( keys %cpe_data )
        {
	my $local_router = $test->{_GLOBAL}{'CPE'}{$cpe}{'router'};
	my $descrip = $cpe_data{$cpe}{'sysDescr'};
	my $software = $cpe_data{$cpe}{'docsDevSwCurrentVers'};
	my $soft_ver = $cpe_data{$cpe}{'SoftwareVersion'};
	my $filename = $cpe_data{$cpe}{'DOCSISFileName'};
	print __OUTPUT "\"$cpe\",\"$local_router\",\"$cpe_data{$cpe}{'ifPhysAddress'}\",\"$descrip\",\"$software\",\"$soft_ver\",\"$filename\"\n";
	}
close (__OUTPUT);



