#!/usr/bin/perl

use strict;
use Router::Statistics;

# this example script should be used on Cisco UBR routers.

my (%interface_information, %routers );
my $result;
my $test= new Router::Statistics;

$result = $test->Router_Add( "10.1.1.1" , "dtv" );
$result = $test->Router_Ready ( "10.1.1.1" );

$result = $test->Router_Test_Connection(\%routers);

if ( scalar( keys %routers )==0 )
  { print "No access to Any of the Routers specified.\n";exit(0); }

$result = $test->UBR_get_DOCSIS_interface_information( \%interface_information );
foreach my $ubr ( keys %interface_information )
       { 
	foreach my $interface ( keys %{$interface_information{$ubr}} )
               { 
		print "$ubr, $routers{$ubr}{'hostName'}, $interface, $interface_information{$ubr}{$interface}{'docsIfSigQIncludesContention'}, $interface_information{$ubr}{$interface}{'docsIfSigQUnerroreds'}, $interface_information{$ubr}{$interface}{'docsIfSigQCorrecteds'}, $interface_information{$ubr}{$interface}{'docsIfSigQUncorrectables'}, $interface_information{$ubr}{$interface}{'docsIfSigQSignalNoise'}, $interface_information{$ubr}{$interface}{'docsIfSigQMicroreflections'}, $interface_information{$ubr}{$interface}{'docsIfSigQEqualizationData'}\n";
               } 
	}

exit(0);

