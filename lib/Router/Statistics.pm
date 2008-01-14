package Router::Statistics;

use strict;
use Router::Statistics::OID;
use Time::localtime;
use Net::SNMP qw (:snmp :asn1);
use Net::Telnet;
use MIME::Base64;
use IO::Select;
use IO::Socket;
use IO::File;
use POSIX;

=head1 NAME

Router::Statistics - Router Statistics and Information Collection

=head1 VERSION

Version 0.99_981

=cut

our $VERSION = '0.99_981';

=head1 SYNOPSIS

Router Statistics and Information Colleciton. Currently this covers a
multitude of areas from different types of routers and in a future release
this will change. There are some 'action' functions within this module which
do need moving to another module so no complaining too much, please.

The following examples shows how to setup the module to retrieve interface
statistics from routers that support the standard IFMIB. All the work about
OIDs etc is taken care of by the module so you are left with a hash tree, rooted
by the router IPs information was received for.

    use Router::Statistics;
    use strict;

    my ( $result, $statistics );
    my ( %routers, %interfaces );

    $statistics = new Router::Statistics();

    $result = $statistics->Router_Add( "10.1.1.1" , "public" );
    $result = $statistics->Router_Ready_Blocking( "10.1.1.1" );
    ....
    $result = $statistics->Router_Add( "10.1.1.200" , "public" );
    $result = $statistics->Router_Ready_Blocking( "10.1.1.200" );

    $result = $statistics->Router_Test_Connection_Blocking(\%routers);

    if ( !%routers )
        { print "No access to Any of the Routers specified.\n";exit(0); }

    $result = $statistics->Router_get_interfaces_Blocking( \%interfaces );

    foreach my $router ( keys %interfaces )
	{
	print "Router IP is '$router'\n";
	print "Router Hostname is '$routers{$router}{'hostName'}'\n";
	foreach my $interface ( keys %{$interfaces{$router}} )
		{
		print "Interface ID '$interface'\n";
		print "Interface Description '$interfaces{$ubr}{$interface}{'ifDescr'}'\n";
		print "Interface ifType '$interfaces{$ubr}{$interface}{'ifType'}'\n";
		print "Interface ifMtu  '$interfaces{$ubr}{$interface}{'ifMtu'}'\n";
		print "Interface ifSpeed '$interfaces{$ubr}{$interface}{'ifSpeed'}'\n";
		print "Interface ifPhysAddress '$interfaces{$ubr}{$interface}{'ifPhysAddress'}'\n";
		print "Interface ifOperStatus '$interfaces{$ubr}{$interface}{'ifOperStatus'}'\n";
		print "Interface ifInOctets '$interfaces{$ubr}{$interface}{'ifInOctets'}'\n";
		print "Interface ifInUcastPkts '$interfaces{$ubr}{$interface}{'ifInUcastPkts'}'\n";
		print "Interface ifInNUcastPkts '$interfaces{$ubr}{$interface}{'ifInNUcastPkts'}'\n";
		print "Interface ifInDiscards '$interfaces{$ubr}{$interface}{'ifInDiscards'}'\n";
		print "Interface ifInErrors '$interfaces{$ubr}{$interface}{'ifInErrors'}'\n";
		print "Interface ifInUnknownProtos '$interfaces{$ubr}{$interface}{'ifInUnknownProtos'}'\n";
		print "Interface ifOutOctets '$interfaces{$ubr}{$interface}{'ifOutOctets'}'\n";
		print "Interface ifOutUcastPkts '$interfaces{$ubr}{$interface}{'ifOutUcastPkts'}'\n";
		print "Interface ifOutNUcastPkts '$interfaces{$ubr}{$interface}{'ifOutNUcastPkts'}'\n";
		print "Interface ifOutDiscards '$interfaces{$ubr}{$interface}{'ifOutDiscards'}'\n";
		print "Interface ifOutErrors '$interfaces{$ubr}{$interface}{'ifOutErrors'}'\n";
		print "\n";
		}
       }

I am currently in need of access to alternative vendor routers, ie. anyone but Cisco ( ABC ) as I only
have real access to Cisco equipment so this code can not be confirmed 100% against anyone else.

I would also like to expand the library to cover other actions , rather than just DOCSIS functions, which
is the primary action focus at the moment.

=head1 FUNCTIONS


=item C<< Router_Add >>

This function adds a Router IP, Community String and Timeout to the internal list of usable routers. It
does not initialise any SNMP functionality at this stage. If no timeout is specified 2 seconds is
the default.

    Router_Add ( "<ip>", "<community>", <timeout> );

Example of Use

    my $result = $test->Router_Add( "10.1.1.1" , "public" );

    is the same as this

    my $result = $test->Router_Add( "10.1.1.1" , "public" , 2 );

=item C<< Router_Remove >>

The function removes a Router IP from the internal list of usable router. If there is an open
SNMP session, it is closed.

Example of Use

    my $result = $test->Router_Remove ( "10.1.1.1" );

=item C<< Router_Remove_All >>

The function removes ALL Router IPs from the internal list of usable router. If there is an open
SNMP session, it is closed.

Example of Use

    my $result = $test->Router_Remove_All ( );

The function was added so you can switch between blocking and non-blocking objects quickly and 
without the need to manually delete any routers already setup.

=item C<< Router_Ready >>

This function sets up the SNMP session object for the IP specified. This is for the non
blocking function set.

Example of Use

    my $result = $test->Router_Ready ( "10.1.1.1" );

=item C<< Router_Ready_Blocking >>

This function sets up the SNMP session object for the IP specified. This is for the
blocking function set.

Example of Use

    my $result = $test->Router_Ready_Blocking ( "10.1.1.1" );

=item C<< Router_Test_Connection >>

This function sends requests for sysUpTime, hostName and sysDescr SNMP variables and 
if successful populates a given hash pointer rooted by the IP of the routers specified.

If the router is not reachable the SNMP session is destroyed ( created by Router_Ready )
and thus not polled for information when other functions are called.

Example of Use

    my %routers;
    my $result = $test->Router_Test_Connection(\%routers);

=item C<< Router_Test_Connection_Blocking >>

This function sends requests for sysUpTime, hostName and sysDescr SNMP variables and
if successful populates a given hash pointer rooted by the IP of the routers specified.

This is the Blocking mirror to the Router_Test_Connection function

Example of Use

    my %routers;
    my $result = $test->Router_Test_Connection_Blocking(\%routers);

=item C<< Router_Return_All >>

This function returns a hash with all the current Routers which were added with Router_Add.
There is little reason to call this function in your own routines and may be move to an 
internal view.

Example of Use

    my %routers = $test->Router_Return_All();

=item C<< Router_get_networks >>

No detail given.

=item C<< Router_get_interfaces >>

This function returns the following for each interface found on the router

    ifDescr ifType ifMtu ifSpeed ifPhysAddress ifAdminStatus ifOperStatus ifLastChange
    ifInOctets ifInUcastPkts ifInNUcastPkts ifInDiscards ifInErrors ifInUnknownProtos
    ifOutOctets ifOutUcastPkts ifOutNUcastPkts ifOutDiscards ifOutErrors ifAlias

The data is returned in a structured hash as follows

    Router IP Address
           Interface Instance Number
                 Interface Attribute ie. ifDescr
		 Interface Attribute ie. ifType

Example of Use

    my %interface_information;
    my $test = $test->Router_get_interfaces( \%interface_information );

=item C<< Router_get_interfaces_Blocking >>

This function returns the following for each interface found on the router and is the 
blocking mirror to the Router_get_interfaces function

This function returns the following for each interface found on the router

    ifDescr ifType ifMtu ifSpeed ifPhysAddress ifAdminStatus ifOperStatus ifLastChange
    ifInOctets ifInUcastPkts ifInNUcastPkts ifInDiscards ifInErrors ifInUnknownProtos
    ifOutOctets ifOutUcastPkts ifOutNUcastPkts ifOutDiscards ifOutErrors ifAlias

The data is returned in a structured hash as follows

    Router IP Address
           Interface Instance Number
                 Interface Attribute ie. ifDescr
                 Interface Attribute ie. ifType

Example of Use

    my %interface_information;
    my $test = $test->Router_get_interfaces_Blocking( \%interface_information );

=item C<< CPE_Add >>

This function adds a CPE IP, Community String and Timeout to the internal list of CPEs that can
be polled for information. All CPE polling is non blocking and also currently requires a unique ID.

It is possible to specify multiple community strings and these will be used in turn should
no response be received, until no more can be tried.

    CPE_Add ( "<ip>", "<community>", "<router IP>", "<unique ID>", <timeout> );

Example of Use

    my $result = $test->CPE_Add( "10.1.2.100" , "public,testing,hello","10.1.1.1","dr3423d3",2 );

=item C<< CPE_Remove >>

The function removes a CPE from the internal list of usable CPEs. If there is an open
SNMP session, it is closed.

    CPE_Remove ("<ip>")

Example of Use

    my $result = $test->CPE_Remove ( "10.1.2.100" );

=item C<< CPE_Ready >>

This function sets up the SNMP session object for the CPE IP specified. This is for the non
blocking function set. (CPE functions do not have non-blocking counterparts)

    CPE_Ready ("<ip>", [ array containing OIDs of the SNMP variables to get ] )

Example of Use

    my $result = $test-> CPE_Ready ( 
			"10.1.2.100",
			[ 1.3.6.1.2.1.1.3.0 , 1.3.6.1.2.1.1.1.0 ] );

    This would retrieve sysUptime and sysDescr for the CPE when the collection functions are
called. You can of course use the references in the OID module provided with this module so
you can use names instead of OIDs.

=item C<< CPE_Return_All >>

No detail given.

=item C<< CPE_export_import_fields >>

No detail given.

=item C<< CPE_export_fields >>

No detail given.

=item C<< CPE_export_schema >>

No detail given.

=item C<< CPE_export_data_start >>

No detail given.

=item C<< CPE_export_data_end >>

No detail given.

=item C<< CPE_export_data >>

No detail given.

=item C<< CPE_gather_all_data_walk >>

No detail given.

=item C<< CPE_gather_all_data >>

This function attempts to collect the CPE data previously configured with CPE_Ready. The
function attempts to use non blocking functionality to do this as quickly as possible,
however the more OIDs to collect per CPE the longer it will take.

Preliminary testing shows the 5000 CPE devices can be polled, with 4 OIDs each, in 45
seconds, making it relatively painless when polling large scale networks.

When using this function and using multiple community strings will cause a significant
slowing of performance.

The function requires a pointer to a hash

    CPE_gather_all_data ( <hash pointer> )

Example of Use

    my $result = $test-> CPE_gather_all_data (
				\%cpe_data 
				);

    The result is rooted by the unique ID and contains the OIDs, converted to name,
with their results. If the CPE is NOT in this hash then it was not successfully 
contacted.

    CPE Hash
        -- Unique ID
           --  OID (converted to name)
           --  OID (converted to name)
           --  etc

=item C<< CPE_Test_Connection >>

=item C<< Get_UBR_Inventory >>

This has been replaced with

UBR_get_Inventory

This function remains for backward compatibility.

=item C<< Export_UBR_Slot_Inventory >>

=item C<< Export_UBR_Port_Inventory >>

=item C<< UBR_get_DOCSIS_upstream_interfaces >>

=item C<< UBR_get_DOCSIS_upstream_interfaces_Blocking >>

=item C<< UBR_get_DOCSIS_interface_information >>

=item C<< UBR_get_DOCSIS_interface_information_Blocking >>

=item C<< UBR_get_DOCSIS_downstream_interfaces >>

=item C<< UBR_get_DOCSIS_downstream_interfaces_Blocking >>

=item C<< UBR_get_CPE_information >>

=item C<< UBR_get_CPE_information_Blocking >>

=item C<< UBR_modify_cpe_DOCSIS_profile >>

=item C<< UBR_reset_cpe_device >>

=item C<< UBR_get_active_cpe_profiles >>

=item C<< UBR_get_active_cpe_profiles_Blocking >>

=item C<< UBR_get_active_upstream_profiles >>

=item C<< UBR_get_active_upstream_profiles_Blocking >>

=item C<< UBR_get_stm >>

The use of the STM functions come with a MASSIVE warning, that due to bugs in Cisco IOS
your UBR ( Cable router ) will drop all currently connected devices if you poll it OUTSIDE
of the configured STM time scope. This is a known defect so you HAVE BEEN WARNED. There are
a couple of possible workarounds however none have been confirmed.

Use of the Non Blocking function should be done with care and the UBR_get_stm_Blocking is
preferred.

Example of Use

    use Router::Statistics;
    use strict;

    my $test= new Router::Statistics;
    my %stm_information;
    my $result = $test->Router_Add( "10.1.1.1" , "public" );
    $result = $test->Router_Ready ( "10.1.1.1" );
    $result = $test->UBR_get_stm( \%stm_information );

The %stm_information hash contains a tree rooted by the IP address of the routers Added
initially and the STM information as follows

     Router IP
          -- STM Instance Number
             --  ccqmEnfRuleViolateID ( never seems to be populated )
             --  ccqmEnfRuleViolateMacAddr  - MAC address of the device
             --  ccqmEnfRuleViolateRuleName - Name of the STM rule specified
             --  ccqmEnfRuleViolateByteCount - The Cisco specification is wrong
             --  ccqmEnfRuleViolateLastDetectTime - The time the violation occured
             --  ccqmEnfRuleViolatePenaltyExpTime - The time the violation finishes


It should be noted that due to another bug not all entries for STM violations end up
in the STM MIB. This appears to be caused by the end time of the STM configuration, if
a devices expiry time is after the end of the STM window, it does not go into the MIB.

=item C<< UBR_get_stm_Blocking >>

The use of the STM functions come with a MASSIVE warning, that due to bugs in Cisco IOS
your UBR ( Cable router ) will drop all currently connected devices if you poll it OUTSIDE
of the configured STM time scope. This is a known defect so you HAVE BEEN WARNED. There are
a couple of possible workarounds however none have been confirmed.

Example of Use

    use Router::Statistics;
    use strict;

    my $test= new Router::Statistics;
    my (%stm_inventory, %stm_telnet_inventory , %routers);
    my $result = $test->Router_Add( "10.1.1.1" , "public" );
    $result = $test->Router_Ready_Blocking ( "10.1.1.1" );
    $result = $test->Router_Test_Connection_Blocking(\%routers);
    $result = $test->UBR_get_stm_Blocking( 
        \%router,
        \%stm_information,
        \%stm_telnet_inventory,
        "telnetlogin",
        "telnetpassword",
        "enablepassword"* );

*The enable password is only required if your login does not put you into the correct
privs account when logged in initially.

The %stm_information and %stm_telnet_inventory hashes contains a tree rooted by the IP address 
of the routers Added initially and the STM information as follows

    Router IP
        -- STM Instance Number
           --  ccqmEnfRuleViolateID ( never seems to be populated )
           --  ccqmEnfRuleViolateMacAddr  - MAC address of the device
           --  ccqmEnfRuleViolateRuleName - Name of the STM rule specified
           --  ccqmEnfRuleViolateByteCount - The Cisco specification is wrong
           --  ccqmEnfRuleViolateLastDetectTime - The time the violation occured
           --  ccqmEnfRuleViolatePenaltyExpTime - The time the violation finishes

It should be noted that due to another bug not all entries for STM violations end up
in the STM MIB. This appears to be caused by the end time of the STM configuration, if
a devices expiry time is after the end of the STM window, it does not go into the MIB.

=item C<< Get_7500_Inventory >>

    The same construct as Get_UBR_Inventory

=item C<< Export_7500_Slot_Inventory >>

=item C<< Export_7500_Port_Inventory >>

=item C<< Get_GSR_Inventory >>

    The same construct as Get_UBR_Inventory

=item C<< Export_GSR_Slot_Inventory >>

=item C<< Export_GSR_Port_Inventory >>

=item C<< Get_7600_Inventory >>

=item C<< Export_7600_Slot_Inventory >>

=item C<< Export_7600_Port_Inventory >>

=item c<< set_format >>

    This function sets the format of the date/time output used in the STM
functions. The default is 

    <year> <MonName> <day> <HH>:<MM>:<SS>

    The format can include the following

    <Year>	- 4 number year ie. 2007
    <MonName>	- Name of the Month, ie January
    <Mon>	- Number of the Month ie. 1 for January
    <Day>	- Day of the month ie. 21
    <HH>	- The hour ie. 10 or 22 ( am or pm )
    <MM>	- The minute
    <SS>	- The second

Example of Use

    use Router::Statistics;
    use strict;

    my $test= new Router::Statistics;
    my $result = $test->set_format("<Year> <Mon> <Day> <HH>:<MM>:<SS>");

=cut

sub new {

        my $self = {};
	bless $self;

	my ( $class , $attr ) =@_;

	while (my($field, $val) = splice(@{$attr}, 0, 2)) 
		{ $self->{_GLOBAL}{$field}=$val; }

	$self->{_GLOBAL}{'STATUS'}="OK";

	$self->set_format();

        return $self;
}

sub get_globals
{ my $self=shift; return $self->{_GLOBAL}; }

sub get_global
{ my $self=shift; my $attribute=shift; return $self->{_GLOBAL}{$attribute}; }

sub get_status
{ 
my $self = shift;
return $self->get_global('STATUS'); 
}

sub CPE_Remove
{
my $self = shift;
my $ip_address = shift;

if ( !$self->{_GLOBAL}{'CPE'}{$ip_address} )
        { 
	print "IP Address not Added '$ip_address'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
	$self->{_GLOBAL}{STATUS}="CPE IP Address Not Added"; return 0; }
print "Removing IP Address '$ip_address'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
$self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'}->close();
delete ($self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'});
delete ($self->{_GLOBAL}{'CPE'}{$ip_address});
return 1;
}


sub CPE_Ready
{
my $self = shift;
my $ip_address = shift;
my $oids = shift;

if ( !$self->{_GLOBAL}{'CPE'}{$ip_address} )
	{ 
	$self->{_GLOBAL}{STATUS}="CPE IP Address Not Added"; return 0; }

my ( $session, $error ) =
		Net::SNMP->session(
			-hostname  =>  $ip_address,
			-community =>  $self->{_GLOBAL}{'CPE'}{$ip_address}{'key'},
			-port 	   =>  161,
			-timeout   =>  $self->{_GLOBAL}{'CPE'}{$ip_address}{'timeout'},
			-version   =>  "snmpv2c",
			-nonblocking => 1,
			-retries   =>  0,
			-translate =>   [-timeticks => 0x0,-octetstring     => 0x0]
				);

if ( $error )
	{
	$self->{_GLOBAL}{'STATUS'}=$error;
	print "Error setting up '$ip_address' is '$error'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
	undef $session;
	return 0;
	}
$self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'}=$session;
$self->{_GLOBAL}{'CPE'}{$ip_address}{'OID'}=$oids;
return 1;
}

sub Router_Ready
{
my $self = shift;

my $ip_address = shift;

if ( !$self->{_GLOBAL}{'Router'}{$ip_address} )
        { $self->{_GLOBAL}{STATUS}="UBR IP Address Not Added"; return 0; }
	
my ($session, $error) = 
		Net::SNMP->session(
      			-hostname  =>  $ip_address,
      			-community =>  $self->{_GLOBAL}{'Router'}{$ip_address}{'key'},
       			-port      =>  161,
 	       		-timeout   =>  $self->{_GLOBAL}{'Router'}{$ip_address}{'timeout'},
 	       		-version   =>  "snmpv2c",
			-translate =>  [-timeticks => 0x0,-octetstring     => 0x0],
			-nonblocking => 1,
       			-retries   =>  2 );
if ( $error )
	{
	$self->{_GLOBAL}{'STATUS'}=$error;
	undef $session;
	return 0;
	}
$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}=$session;
return 1;
}

sub Router_Ready_Blocking
{
my $self = shift;

my $ip_address = shift;

if ( !$self->{_GLOBAL}{'Router'}{$ip_address} )
        { $self->{_GLOBAL}{STATUS}="UBR IP Address Not Added"; return 0; }

my ($session, $error) =
		Net::SNMP->session(
			-hostname  =>  $ip_address,
			-community =>  $self->{_GLOBAL}{'Router'}{$ip_address}{'key'},
			-port      =>  161,
			-timeout   =>  $self->{_GLOBAL}{'Router'}{$ip_address}{'timeout'},
			-version   =>  "snmpv2c",
			-translate =>  [-timeticks => 0x0,-octetstring     => 0x0],
			-nonblocking => 0,
			-retries   =>  2 );
if ( $error )
	{
	$self->{_GLOBAL}{'STATUS'}=$error;
	undef $session;
	return 0;
	}
$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}=$session;
return 1;
}


sub CPE_Return_All
{
my $self = shift;
return $self->{_GLOBAL}{'CPE'};
}

sub Router_Return_All
{
my $self = shift;
return $self->{_GLOBAL}{'Router'};
}

sub CPE_Add
{
my $self = shift;
my $ip_address = shift;
my $snmp_key = shift;
my $router = shift;
my $cpe_id = shift;
my $timeout = shift;
if ( !$ip_address || !$snmp_key )
	{ $self->{_GLOBAL}{STATUS}="No IP Address or SNMP Key Specified."; return 0; }

if ( !$timeout )
	{ $timeout=2; }

$self->{_GLOBAL}{'CPE'}{$ip_address}{'keys_to_test'}=join(',',(split(/,/,$snmp_key))[1,2,3,4,5,6,7,8,9,10]);
$self->{_GLOBAL}{'CPE'}{$ip_address}{'key'}=(split(/,/,$snmp_key))[0];
$self->{_GLOBAL}{'CPE'}{$ip_address}{'router'}=$router;
$self->{_GLOBAL}{'CPE'}{$ip_address}{'timeout'}=$timeout;
$self->{_GLOBAL}{'CPE'}{$ip_address}{'id'} = $cpe_id;

print "Keys left are '".$self->{_GLOBAL}{'CPE'}{$ip_address}{'keys_to_test'}."'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
print "Key is are '".$self->{_GLOBAL}{'CPE'}{$ip_address}{'key'}."'\n" if $self->{_GLOBAL}{'DEBUG'}==1;

return 1;
}

sub Router_Add
{
my $self = shift;
my $ip_address = shift;
my $snmp_key = shift;
my $timeout = shift;
if ( !$ip_address || !$snmp_key )
        { $self->{_GLOBAL}{STATUS}="No IP Address or SNMP Key Specified."; return 0; }

if ( !$timeout ) { $timeout=2; }
$self->{_GLOBAL}{'Router'}{$ip_address}{'key'}=$snmp_key;
$self->{_GLOBAL}{'Router'}{$ip_address}{'timeout'}=$timeout;
return 1;
}

sub Router_Remove_All
{
my $self = shift;
my $all_routers = $self->Router_Return_All();
foreach my $router ( keys %{$all_routers} )
	{
	$self->Router_Remove($router);
	}
return 1;
}

sub Router_Remove
{
my $self = shift;
my $ip_address = shift;
if ( !$ip_address )
	{ $self->{_GLOBAL}{STATUS}="No IP Address Specified."; return 0; }
if ( $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'} )
	{ $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->close(); }
delete ( $self->{_GLOBAL}{'Router'}{$ip_address} );
return 1;
}

sub CPE_export_import_fields
{
my $self = shift;
my $fields = shift;
$self->{_GLOBAL}{'EXPORT'}{'CPE'}=$fields;
return 1;
}

sub CPE_export_fields
{
my $self = shift;
return $self->{_GLOBAL}{'EXPORT'}{'CPE'};
}

sub CPE_export_schema
{
my $self = shift;
my $handle = shift;
my $format = shift;
my $fields = $self->CPE_return_export_fields();

if ( $format=~/xml-dtd/i )
        {
	# we generate a DTD and XML schema, then the user can break them up as needed
	my $output;
	print $handle "<!ELEMENT cpe (";
	foreach my $field ( @{$fields} ) { $output.="$field,"; } chop($output);
	print $handle $output;
	print $handle ")>\n";
        print $handle "<cpe>\n";
        foreach my $field ( @{$fields} ) { print $handle "<!ELEMENT> $field (#PCDATA)>\n"; }
        }

if ( $format!~/xml-dtd/i )
	{ $self->{_GLOBAL}{STATUS}="Only xml-dtd supported at this time.";return 0;}

return 1;
}

sub CPE_export_data_start
{
my $self = shift;
$self->{_GLOBAL}{'EXPORT'}{'START'}=1;
return 1;
}

sub CPE_export_data_end
{
my $self;
$self->{_GLOBAL}{'EXPORT'}{'START'}=0;
return 1;
}

sub CPE_export_data
{
my $self = shift;
my $ip_address = shift;
my $cpe_data = shift;
my $format = shift;
my $handle = shift;

if ( !${$cpe_data}{$ip_address} )
	{ $self->{_GLOBAL}{STATUS}="No CPE Data Found."; return 0; }

if ( !$format )
	{ $self->{_GLOBAL}{STATUS}="Format Not Specified."; return 0; }

if ( !$handle )
	{ $self->{_GLOBAL}{STATUS}="Output Handle Not Specified."; return 0; }

my $fields = $self->CPE_export_fields();

if ( !$fields )
        { $self->{_GLOBAL}{STATUS}="Output Fields Not Specified."; return 0; }

if ( $self->{_GLOBAL}{'EXPORT'}{'START'}==1 && $format=~/xml/i )
	{
	print $handle "<?xml version=\"1.0\"?>\n";
	$self->{_GLOBAL}{'EXPORT'}{'START'}=0;
	}

if ( $self->{_GLOBAL}{'EXPORT'}{'START'}==1 && $format=~/csv/i )
	{
	my $output="";
	foreach my $field ( @{$fields} ){ $output.="\"".$field."\","; }; chop($output);
	print $handle $output."\n";
	$self->{_GLOBAL}{'EXPORT'}{'START'}=0;
	}

if ( $format=~/xml/i )
	{
	print $handle "<cpe>\n";
	foreach my $field ( @{$fields} )
		{ print $handle "<$field>".${$cpe_data}{$ip_address}{$field}."</$field>\n"; 
		}
	print $handle "</cpe>\n";
	}

if ( $format=~/csv/i )
	{
	my $output;
	foreach my $field ( @{$fields} )
		{ $output.="\"".${$cpe_data}{$ip_address}{$field}."\","; }
	chop($output);
	$output.="\n";
	print $handle $output;
	}

if ( $format!~/xml/i && $format!~/csv/i )
	{ $self->{_GLOBAL}{STATUS}="Format Specified is not supported, only 'xml or csv'."; return 0; }

return 1;
}

sub CPE_gather_all_data_walk
{
my $self = shift;
my $data = shift;

# Entry into the function is a point to a hash to store the data
# the result is a hash with the following

my $cpes=$self->CPE_Return_All();

if ( scalar ( keys %{$cpes}==0 ) )
        { $self->{_GLOBAL}{'STATUS'}="No CPEs setup"; return 0; }

my $snmp_variables = Router::Statistics::OID->CPE_populate_oid();

foreach my $cpe ( keys %{$cpes} )
	{
		my ($interface_information)=${$cpes}{$cpe}{'SESSION'}->
        	        get_table(
        	                -callback       => [ \&validate_one_cpe, $data, $cpe, $snmp_variables ],
        	                -baseoid => ${$cpes}{$cpe}{'OID'} );
	}

snmp_dispatcher();

if ( scalar ( keys %{$data} ) == 0 )
        { $self->{_GLOBAL}{'STATUS'}="No CPE Data Found.\n"; return 0; }

return 1;
}

sub CPE_gather_all_data
{
my $self = shift;
my $data = shift;

# Entry into the function is a point to a hash to store the data
# the result is a hash with the following

my $cpes=$self->CPE_Return_All();

if ( scalar ( keys %{$cpes}==0 ) )
        { $self->{_GLOBAL}{'STATUS'}="No CPEs setup"; return 0; }

my $snmp_variables = Router::Statistics::OID->CPE_populate_oid();

foreach my $cpe ( keys %{$cpes} )
	{
		my ($interface_information)=${$cpes}{$cpe}{'SESSION'}->
        	        get_request(
        	                -callback       => [ \&get_cpe_information, $cpe, $data, $snmp_variables ],
        	                -varbindlist =>
        	                  ${$cpes}{$cpe}{'OID'} );
	}

snmp_dispatcher();

foreach my $cpe ( keys %{$data} )
	{
	foreach my $attribute ( keys %{${$data}{$cpe}} )
		{
		if ( $attribute=~/ifPhysAddress/)
			{
			${$data}{$cpe}{$attribute}=_convert_mac_address( ${$data}{$cpe}{$attribute} );
			}
		}
	}

if ( scalar ( keys %{$data} ) == 0 )
        { $self->{_GLOBAL}{'STATUS'}="No CPE Data Found.\n"; return 0; }

return 1;
}

sub Router_get_networks
{
my $self = shift;
my $data = shift;
my $interface_data = shift;
my $router_data = shift;

my $output;

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->Router_Link_Map_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
        my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_table(
                -callback       => [ \&validate_six_net, $data, $ip_address, $snmp_variables ],
               -baseoid => ${$snmp_variables}{'PRIVATE_atEnt'} );
        }
snmp_dispatcher();

foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
        my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_table(
                -callback       => [ \&validate_four_net, $data, $ip_address, $snmp_variables ],
               -baseoid => ${$snmp_variables}{'PRIVATE_ipEnt'} );
        }
snmp_dispatcher();

foreach my $ip_address ( keys %{$data} )
	{
	foreach my $interfaces ( keys %{${$data}{$ip_address}} )
		{
		foreach my $ips ( keys %{${$data}{$ip_address}{$interfaces}{'address'}} )
			{
			${$data}{$ip_address}{$interfaces}{'address'}{$ips}{'atPhysAddress'}=
				_convert_mac_address(${$data}{$ip_address}{$interfaces}{'atPhysAddress'});
			}
		}
	}

foreach my $ip_address ( keys %{$data} )
	{
	foreach my $interfaces ( keys %{${$data}{$ip_address}} )
		{
		foreach my $ips ( keys %{${$data}{$ip_address}{$interfaces}{'address'}} )
			{
			my $real_address = $self->_IpQuadToInt( $ips );
			my $real_netmask = $self->_IpQuadToInt( ${$data}{$ip_address}{$interfaces}{'address'}{$ips}{'ipAdEntNetMask'} );
			my $network_address = $real_address&$real_netmask ;
			${$data}{$ip_address}{$interfaces}{'ipAdEntNetWork'} = $self->_IpIntToQuad( $network_address );
			${$data}{$ip_address}{$interfaces}{'ipAdEntNetMask'} = ${$data}{$ip_address}{$interfaces}{'address'}{$ips}{'ipAdEntNetMask'};
			}
		}
	}

my %interface_remapper;
my %interface_map;
my %remote_map;
my %network_map;
my %router_owners;

foreach my $router ( keys %{$data} )
        {
        foreach my $interface ( keys %{${$data}{$router}} )
                {
                foreach my $ip_address ( keys %{${$data}{$router}{$interface}{'address'}} )
                        {
                        next unless ${$data}{$router}{$interface}{'address'}{$ip_address}{'ipAdEntNetMask'};
                        $router_owners{$ip_address}=$router;
                        my $network_layer = $self->_IpQuadToInt( $ip_address )
                                        &
                                        $self->_IpQuadToInt(
                                                ${$data}{$router}{$interface}{'address'}{$ip_address}{'ipAdEntNetMask'}
                                                        );
                        $network_map { $network_layer } {$ip_address}=$router;
                        if ( ${$data}{$router}{$interface}{'address'}{$ip_address}{'ipAdEntIfIndex'} )
                                {
                                $interface_map{${$data}{$router}{$interface}{'ipAdEntNetWork'}}{$router}=1;
                                }
                                else
                                {
                                $remote_map{$router}{${$interface_data}{$router}{$interface}{'ifDescr'} } { $ip_address } =1;
                                }
                        }
                }
        }

$output.="router_ip,router_name,link_ifDescr,local_ip,remote_ip,remote_router_ip,remote_router_name,netmask,link_ifAdminStatus,link_ifOperStatus,link_ifAlias\n";

foreach my $router ( keys %{$data} )
        {
        foreach my $interface ( keys %{${$data}{$router}} )
                {
                my ($local,$remote,$remote_router,@remote_link, $netmask, $network, @network_link );
                foreach my $ip_address ( keys %{${$data}{$router}{$interface}{'address'}} )
                        {
                        next unless ${$data}{$router}{$interface}{'address'}{$ip_address}{'ipAdEntNetMask'};
                        $netmask= ${$data}{$router}{$interface}{'address'}{$ip_address}{'ipAdEntNetMask'};
                        $local=$ip_address;
                        @remote_link=keys %{ $remote_map{$router}{ ${$interface_data}{$router}{$interface}{'ifDescr'} }};
                        if ( scalar(@remote_link) >1 ) {
                                $remote=""; } else { $remote=$remote_link[0]; }
                        if ( !$remote )
                                {
                                $remote=$ip_address if $interface_remapper{$ip_address}{$router}{'type'}=~/remote/i;
                                }
                        @remote_link=keys %{$interface_map{${$data}{$router}{$interface}{'ipAdEntNetWork'}}};
                        $remote_router="";
                        foreach my $not_local ( @remote_link )
                                { $remote_router = $not_local if $self->_IpQuadToInt($not_local)!=$self->_IpQuadToInt($ip_address); }
                        if ( $self->_IpQuadToInt($remote_router)==$self->_IpQuadToInt($router) )
                                { $remote_router=""; }
                        }

                if ( !$remote )
                        {
                        $network= $self->_IpQuadToInt($local)&$self->_IpQuadToInt($netmask);
                        @network_link = keys %{ $network_map{ $network } };
                        if ( scalar(@network_link)>1 )
                                {
                                foreach my $not_local ( @network_link )
                                        {
                                        $remote = $not_local if  $self->_IpQuadToInt($not_local)!=$self->_IpQuadToInt($local);
                                        }
                                }
                        }

                 $output .="$router,${$router_data}{$router}{'hostName'},$interface,${$interface_data}{$router}{$interface}{'ifDescr'},$local,$remote,$router_owners{$remote},${$router_data}{$router_owners{$remote}}{'hostName'},$netmask,${$interface_data}{$router}{$interface}{'ifAdminStatus'},${$interface_data}{$router}{$interface}{'ifOperStatus'},${$interface_data}{$router}{$interface}{'ifAlias'}\n";
                }
        }

return $output;
}

sub UBR_get_stm
{
# This function is not going to have the extra STM information added
# as it should not really be run anyway and it would only be a repition
# of code.
my $self = shift;
my $router_info = shift;
my $data = shift;
my $telnet_data = shift;
my $username = shift;
my $password = shift;
my $enable = shift;

my %priv_time;

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->STM_populate_oid();
my $telnet_commands = Router::Statistics::OID->telnet_commands();
my $time = Router::Statistics::OID->ntp_populate_oid();

foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
        print "Doing STM MAP for '$ip_address'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_table(
                        -callback       => [ \&validate_rule_base, $data, $ip_address, $snmp_variables ],
                        -baseoid => ${$snmp_variables}{'PRIVATE_stm_rule_base'} );
        }
snmp_dispatcher();

foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	print "Doing ntp for '$ip_address'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
        my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_request (
			-callback       => [ \&validate_callback, $ip_address, $data, $time],
			-varbindlist => [ ${$time}{'cntpSysClock'} ] );
	}

snmp_dispatcher();
foreach my $ip_address ( keys %{$current_ubrs} )
        { $self->convert_ntp_time_mask(${$data}{$ip_address}{'cntpSysClock'}, $data, $ip_address ); }

foreach my $ip_address ( keys %{$current_ubrs} )
	{
	print "UBR thinks it is Hour is '${$data}{$ip_address}{'time'}{'hour'}' min is '${$data}{$ip_address}{'time'}{'min'}'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
	foreach my $stm_rules ( keys %{${$data}{$ip_address}{'stm_rule_set'}} )
		{
		my $end_hour_time = sprintf("%d",( ${$data}{$ip_address}{'stm_rule_set'}{$stm_rules}{'ccqmCmtsEnfRuleStartTime'} +
					(${$data}{$ip_address}{'stm_rule_set'}{$stm_rules}{'ccqmCmtsEnfRuleDuration'}/60)));
		if ( ${$data}{$ip_address}{'stm_rule_set'}{$stm_rules}{'ccqmCmtsEnfRuleStartTime'}>${$data}{$ip_address}{'time'}{'hour'} )
			{
			${$data}{$ip_address}{'stm_rule_not_allowed'}++;
			print "We are removing '$stm_rules' not started\n" if $self->{_GLOBAL}{'DEBUG'}==1;
			}

                if ( ${$data}{$ip_address}{'time'}{'hour'}>=${$data}{$ip_address}{'stm_rule_set'}{$stm_rules}{'ccqmCmtsEnfRuleStartTime'}
                        &&
                        ${$data}{$ip_address}{'time'}{'hour'}<$end_hour_time
                        &&
                        ( ${$data}{$ip_address}{'time'}{'hour'}<=($end_hour_time-1) && ${$data}{$ip_address}{'time'}{'min'}<45 )
                        )
			{
			}
			else
			{
			${$data}{$ip_address}{'stm_rule_not_allowed'}++;
			print "We are removing '$stm_rules' end point failure\n" if $self->{_GLOBAL}{'DEBUG'}==1;
			}		
		}
	}

foreach my $ip_address ( keys %{$current_ubrs} )
        {
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	if ( ${$data}{$ip_address}{'stm_rule_not_allowed'}!=scalar( keys %{${$data}{$ip_address}{'stm_rule_set'}} ) )
		{
		my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
			get_table(
				-callback=> [ \&validate_two_plain, $data, $ip_address, $snmp_variables ],
				-baseoid => ${$snmp_variables}{'PRIVATE_stm_base'} );
		}
	}
snmp_dispatcher();
foreach my $ip_address ( keys %{$current_ubrs} )
	{
	if ( ${$data}{$ip_address}{'stm_rule_not_allowed'}!=scalar( keys %{${$data}{$ip_address}{'stm_rule_set'}} ) )
		{
		foreach my $instance ( keys %{${$data}{$ip_address}} )
			{
			next if $instance=~/^cntpSysClock/ig;
			${$data}{$ip_address}{$instance}{'ccqmEnfRuleViolateMacAddr'}=
				$self->_convert_mac_address( ${$data}{$ip_address}{$instance}{'ccqmEnfRuleViolateMacAddr'} );
			${$data}{$ip_address}{$instance}{'ccqmEnfRuleViolateLastDetectTime'}=
				$self->convert_time_mask( ${$data}{$ip_address}{$instance}{'ccqmEnfRuleViolateLastDetectTime'} );
			${$data}{$ip_address}{$instance}{'ccqmEnfRuleViolatePenaltyExpTime'}=
				$self->convert_time_mask( ${$data}{$ip_address}{$instance}{'ccqmEnfRuleViolatePenaltyExpTime'} );
			}
		}
	}
return 1;
}

sub UBR_get_stm_Blocking
{
my $self = shift;
my $router_info = shift;
my $data = shift;
my $telnet_data = shift;
my $username = shift;
my $password = shift;
my $enable = shift;

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my ( $foo, $bar );

my $snmp_variables = Router::Statistics::OID->STM_populate_oid();
my $telnet_commands = Router::Statistics::OID->telnet_commands();
my $time = Router::Statistics::OID->ntp_populate_oid();

foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
        print "Doing STM MAP for '$ip_address'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
        my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_table( -baseoid => ${$snmp_variables}{'PRIVATE_stm_rule_base'} );
	while(($foo, $bar) = each(%{$profile_information}))
		{
		my $instance;
		foreach my $attribute ( keys %{$snmp_variables} )
			{
			if ( $attribute!~/^PRIVATE/ )
				{
				if ( $foo =~ /^${$snmp_variables}{$attribute}/)
					{
		                        my $new_oid=$foo;
        		                $new_oid=~s/${$snmp_variables}{$attribute}//g;
        	                	my $name;
        	                	foreach my $character ( split(/\./,$new_oid) )
        	                	        { next if $character<15; $name.=chr($character); }
        	                	$name=~s/^\s*//; $name=~ s/\s*$//;
                        		${$data}{$ip_address}{'stm_rule_set'}{$name}{$attribute}=$bar;
					}
				}
                        }
                }
        }

foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};

	my ($time_request)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_request ( -varbindlist => [
                                ${$time}{'cntpSysClock'} 
				] );

	$self->convert_ntp_time_mask( $time_request->{ ${$time}{'cntpSysClock'} }, $data, $ip_address );

	print "UBR thinks its Hour is '${$data}{$ip_address}{'time'}{'hour'}' min is '${$data}{$ip_address}{'time'}{'min'}'\n" if $self->{_GLOBAL}{'DEBUG'}==1;

	foreach my $stm_rules ( keys %{${$data}{$ip_address}{'stm_rule_set'}} )
		{
		print "Rule name2 is '$stm_rules'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
		print "Start time2 is '${$data}{$ip_address}{'stm_rule_set'}{$stm_rules}{'ccqmCmtsEnfRuleStartTime'}'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
		
                my $end_hour_time = sprintf("%d",( ${$data}{$ip_address}{'stm_rule_set'}{$stm_rules}{'ccqmCmtsEnfRuleStartTime'} +
                                        (${$data}{$ip_address}{'stm_rule_set'}{$stm_rules}{'ccqmCmtsEnfRuleDuration'}/60)));

		print "End time2 is '$end_hour_time'\n" if $self->{_GLOBAL}{'DEBUG'}==1;

                if ( ${$data}{$ip_address}{'stm_rule_set'}{$stm_rules}{'ccqmCmtsEnfRuleStartTime'}>${$data}{$ip_address}{'time'}{'hour'} )
                        {
                        ${$data}{$ip_address}{'stm_rule_not_allowed'}++;
                        print "We are removing '$stm_rules' not started\n" if $self->{_GLOBAL}{'DEBUG'}==1;
                        }

		print "hour is '${$data}{$ip_address}{'time'}{'hour'}' start is '${$data}{$ip_address}{'stm_rule_set'}{$stm_rules}{'ccqmCmtsEnfRuleStartTime'}'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
		print "end is '".($end_hour_time-1)."' min is '${$data}{$ip_address}{'time'}{'min'}'\n" if $self->{_GLOBAL}{'DEBUG'}==1;

                if ( ${$data}{$ip_address}{'time'}{'hour'}>=${$data}{$ip_address}{'stm_rule_set'}{$stm_rules}{'ccqmCmtsEnfRuleStartTime'}
			&& 
                        ${$data}{$ip_address}{'time'}{'hour'}<$end_hour_time 
			&&
                        ( ${$data}{$ip_address}{'time'}{'hour'}<=($end_hour_time-1) && ${$data}{$ip_address}{'time'}{'min'}<45 )
			)
                        {
                        }
                        else
                        {
                        ${$data}{$ip_address}{'stm_rule_not_allowed'}++;
                        print "We are removing '$stm_rules' end point failure2\n" if $self->{_GLOBAL}{'DEBUG'}==1;
                        }
                }

	if ( ${$data}{$ip_address}{'stm_rule_not_allowed'}!=scalar( keys %{${$data}{$ip_address}{'stm_rule_set'}} ) )
		{
		print "We match profiles so can poll for STM2.\n" if $self->{_GLOBAL}{'DEBUG'}==1;
        	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
        	        get_table( -baseoid => ${$snmp_variables}{'PRIVATE_stm_base'} );

 	       while(($foo, $bar) = each(%{$profile_information}))
 	               {
 	               my $instance;
 	               if ( $foo=~/^${$snmp_variables}{'ccqmEnfRuleViolateMacAddr'}.(\d+).(\d+)/ )
 	                       { $instance="$1:$2"; ${$data}{$ip_address}{$instance}{'ccqmEnfRuleViolateMacAddr'}=_convert_mac_address($bar); }
	
       		       if ( $foo=~/^${$snmp_variables}{'ccqmEnfRuleViolateLastDetectTime'}.(\d+).(\d+)/ )
        	                { $instance="$1:$2"; ${$data}{$ip_address}{$instance}{'ccqmEnfRuleViolateLastDetectTime'}=$self->convert_time_mask($bar); }
	
        	       if ( $foo=~/^${$snmp_variables}{'ccqmEnfRuleViolatePenaltyExpTime'}.(\d+).(\d+)/ )
        	                { $instance="$1:$2"; ${$data}{$ip_address}{$instance}{'ccqmEnfRuleViolatePenaltyExpTime'}=$self->convert_time_mask($bar); }
	
        	       if ( $foo=~/^${$snmp_variables}{'ccqmEnfRuleViolateRuleName'}.(\d+).(\d+)/ )
        	                { $instance="$1:$2"; ${$data}{$ip_address}{$instance}{'ccqmEnfRuleViolateRuleName'}=$bar; }

        	       if ( $foo=~/^${$snmp_variables}{'ccqmEnfRuleViolateByteCount'}.(\d+).(\d+)/ )
        	                { $instance="$1:$2"; ${$data}{$ip_address}{$instance}{'ccqmEnfRuleViolateByteCount'}=$bar; }

 	               if ( $foo=~/^${$snmp_variables}{'ccqmEnfRuleViolateID'}.(\d+).(\d+)/ )
 	                       { $instance="$1:$2"; ${$data}{$ip_address}{$instance}{'ccqmEnfRuleViolateID'}=$bar; }
 	               delete ${$profile_information}{$foo};
 	               }

		if ( $username && $password )
			{

			my $router_name = ${$router_info}{$ip_address}{'hostName'};
			if ( $router_name )
				{
				my $safe_router_name=$router_name;
        			my $router_t = new Net::Telnet (Timeout => 20,
                                        Telnetmode => 0,
                                        Prompt => "/^Username :|Password :|$safe_router_name/" );
				my $error_change = $router_t->errmode("return");
				my $login_router = $router_t->open( $ip_address );
	        		if ( $login_router )
					{
					$router_t->login($username,$password);
					if ( $enable )
						{
						my $line = $router_t->print("enable");
						$router_t->waitfor("/Password/");
						$line = $router_t->print( $enable );
						$router_t->waitfor("/$safe_router_name/");
						}
					my $stm_command = decode_base64(${$telnet_commands}{'stm_command'});
					my $line = $router_t->print( decode_base64(${$telnet_commands}{'termline'}) ) ;
					$router_t->waitfor("/$router_name\#/");
					my @lines = $router_t->cmd(String => $stm_command ,Prompt  => "/$safe_router_name\#/");
					$router_t->close();
					# we need to make sure we handle the multiple domains within the output
					# as Telnet commands are notorious for providing correct but repeating idents
					# these need to be mapped into a unique handler. Lets face it though, using
					# telnet is just a really bad idea.
					$a=0;
					foreach $line ( @lines )
						{
						next if $line=~/^$safe_router_name/;
						next unless $line=~/^[0-9]/;
						next unless length($line)>10;
						chop($line);
						my @fields = (split(/\W*\s+\W*/,$line));
						my $instance_telnet = "$a".$fields[0];
						${$telnet_data}{$ip_address}{$instance_telnet}{'ccqmEnfRuleViolateMacAddr'}=$fields[1];
						${$telnet_data}{$ip_address}{$instance_telnet}{'ccqmEnfRuleViolateRuleName'}=$fields[2];
						${$telnet_data}{$ip_address}{$instance_telnet}{'ccqmEnfRuleViolateLastDetectTime'}="$fields[4] $fields[5]";
						${$telnet_data}{$ip_address}{$instance_telnet}{'ccqmEnfRuleViolatePenaltyExpTime'}="$fields[6] $fields[7]";
						$a++;
						}
					}
				}
			}
		# recheck router is still up, after a poll ?
		# we can not do this in non blocking mode, alas.
		#
		my ($time_request)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
			get_request ( -varbindlist => [ ${$time}{'cntpSysClock'} ] );
		if (  $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->error )
			{
			# We failed to get ntp time from the router we just polled.
			# we stop all polling and return out.
			print "Router failed to return after STM poll we are exiting.\n" if $self->{_GLOBAL}{'DEBUG'}==1;
			return 1;
			}
		}
	}
		
return 1;
}



sub Router_get_interfaces
{
my $self = shift;
my $data = shift;

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->Router_interface_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
        {
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table(
		-callback       => [ \&validate_one, $data, $ip_address, $snmp_variables ],
		-baseoid => ${$snmp_variables}{'PRIVATE_interface_base'} );
	}
snmp_dispatcher();

foreach my $ip_address ( keys %{$current_ubrs} )
        {
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table(
		-callback       => [ \&validate_one, $data, $ip_address, $snmp_variables ],
		-baseoid => ${$snmp_variables}{'ifAlias'} );
	}
snmp_dispatcher();

foreach my $ip_address ( keys %{$data} )
	{
	foreach my $interfaces ( keys %{${$data}{$ip_address}} )
		{
		${$data}{$ip_address}{$interfaces}{'ifPhysAddress'}=
			_convert_mac_address(${$data}{$ip_address}{$interfaces}{'ifPhysAddress'}); 
		${$data}{$ip_address}{$interfaces}{'ifAdminStatus'}=
			('0_Unknown','1_Up','2_Down','3_Testing')[${$data}{$ip_address}{$interfaces}{'ifAdminStatus'}];
		${$data}{$ip_address}{$interfaces}{'ifOperStatus'}=
			('0_Unknown','1_Up','2_Down','3_Testing','4_Unknown','5_Dormant','6_NotPresent','7_LowerLayerDown')
				[${$data}{$ip_address}{$interfaces}{'ifOperStatus'}];
		}
	}
return 1;
}

sub Router_get_interfaces_Blocking
{
my $self = shift;
my $data = shift;

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->Router_interface_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
        {
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ( $foo, $bar );
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table(
		-baseoid => ${$snmp_variables}{'PRIVATE_interface_base'} );
	while(($foo, $bar) = each(%{$profile_information}))
		{
		next unless($foo =~ /^${$snmp_variables}{'PRIVATE_interface_base'}.(\d+)/);
		if ( $foo=~/^${$snmp_variables}{'ifDescr'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifDescr'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifType'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifType'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifMtu'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifMtu'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifSpeed'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifSpeed'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifPhysAddress'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifPhysAddress'}=_convert_mac_address($bar); }
		if ( $foo=~/^${$snmp_variables}{'ifAdminStatus'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifAdminStatus'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifOperStatus'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifOperStatus'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifLastChange'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifLastChange'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifInOctets'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifInOctets'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifInUcastPkts'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifInUcastPkts'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifInNUcastPkts'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifInNUcastPkts'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifInDiscards'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifInDiscards'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifInErrors'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifInErrors'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifInUnknownProtos'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifInUnknownProtos'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifOutOctets'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifOutOctets'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifOutUcastPkts'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifOutUcastPkts'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifOutNUcastPkts'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifOutNUcastPkts'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifOutDiscards'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifOutDiscards'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'ifOutErrors'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifOutErrors'}=$bar; }
		delete ${$profile_information}{$foo};
		}

        ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_table(
                -baseoid => ${$snmp_variables}{'ifAlias'} );
        while(($foo, $bar) = each(%{$profile_information}))
                {
		if ( $foo=~/^${$snmp_variables}{'ifAlias'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'ifAlias'}=$bar; }
		delete ${$profile_information}{$foo};
		}

	}

return 1;
}

sub Get_7500_Inventory
{
my $self = shift;
my $data = shift;
my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }
my $snmp_variables = Router::Statistics::OID->Router_inventory_oid();

my %temp;

foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
        my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_table(
                        -callback       => [ \&validate_one, \%temp, $ip_address, $snmp_variables ],
                        -baseoid => ${$snmp_variables}{'PRIVATE_inventory'} );
        }
snmp_dispatcher();

foreach my $ip_address ( keys %temp )
        {
        foreach my $relative (  keys %{$temp{$ip_address}} )
                {
		if ( $temp{$ip_address}{$relative}{'entPhysicalName'}=~/^Line Card (\d+)/ )
			{ $temp{$ip_address}{'rev'}{ $1 }{'main'}=$relative; }
		if ( $temp{$ip_address}{$relative}{'entPhysicalName'}=~/^RSP at Slot (\d+)/ )
			{ $temp{$ip_address}{'rev'}{ $1 }{'main'}=$relative; }
		if ( $temp{$ip_address}{$relative}{'entPhysicalName'}=~/^Card Slot (\d+), Bay (\d+)/ )
			{ $temp{$ip_address}{'rev'}{ $1 }{'child'}{$2}=$relative; }
		if ( $temp{$ip_address}{$relative}{'entPhysicalName'}=~/^PA at Slot (\d+), Bay (\d+)/ )
			{ ${$data}{$ip_address}{'slot'}{$1}{'child'}{$2}{'name'}="Empty"; }
                }
        foreach my $a ( keys %{$temp{$ip_address}{'rev'}} )
                {
		foreach my $child ( keys %{$temp{$ip_address}{'rev'}{$a}{'child'}} )
			{
	                foreach my $attribute ( keys %{$snmp_variables} )
        	                {
        	                next if $attribute=~/PRIVATE/;
        	                ${$data}{$ip_address}{'slot'}{$a}{'child'}{$child}{$attribute}=
                	                $temp{$ip_address}{ $temp{$ip_address}{'rev'}{$a}{'child'}{$child} } {$attribute};
				}
                        }

                foreach my $attribute ( keys %{$snmp_variables} )
                        {
                        next if $attribute=~/PRIVATE/;
                        ${$data}{$ip_address}{'slot'}{$a}{'main'}{$attribute}=
                                $temp{$ip_address}{ $temp{$ip_address}{'rev'}{$a}{'main'} }{$attribute};
                        }
		#${$data}{$ip_address}{'slot'}{$a}{'main'}{'entPhysicalDescr'}=$temp{$ip_address}{ $temp{$ip_address}{'rev'}{$a}{'main'} }{'entPhysicalDescr'};
                }
        $temp{$ip_address}{'1'}{'entPhysicalDescr'}=~/^(\d+)/;
        ${$data}{$ip_address}{'total_slots'}=substr($1,2,2);
        }
undef %temp;
return 1;
}

sub Export_7500_Slot_Inventory
{
my $self = shift;
my $data = shift;
my $router_list = shift;
my $handle = shift;
my $format = shift;

if ( scalar ( keys %{$data} ) == 0 )
	{ $self->{_GLOBAL}{'STATUS'}="No Router Data Available."; return 0; }

if ( scalar ( keys %{$router_list} ) == 0 )
	{ $self->{_GLOBAL}{'STATUS'}="Router List Required."; return 0; }

if ( !$handle )
	{ $self->{_GLOBAL}{'STATUS'}="File Handle Required."; return 0; }

if ( $format!~/csv/i )
	{ $self->{_GLOBAL}{'STATUS'}="Only CSV Format Supported."; return 0; }

if ( $format=~/csv/i )
	{ print $handle "ip_address,hostname,slot,bay,description,serialnumber,partcode\n"; }

foreach my $ip_address ( keys %{$data} )
        {
	if ( $format=~/csv/i )
		{
		for(my $slot=0;$slot<${$data}{$ip_address}{'total_slots'};$slot++)
			{
			if ( !${$data}{$ip_address}{'slot'}{$slot}{'main'}{'entPhysicalDescr'} )
				{ ${$data}{$ip_address}{'slot'}{$slot}{'main'}{'entPhysicalDescr'}="Empty"; }
			print $handle "\"$ip_address\",\"${$router_list}{$ip_address}{'hostName'}\",\"$slot\",";
			print $handle "\"Main\",\"".${$data}{$ip_address}{'slot'}{$slot}{'main'}{'entPhysicalDescr'}."\",";
			print $handle "\"".${$data}{$ip_address}{'slot'}{$slot}{'main'}{'entPhysicalSerialNum'}."\",";
			print $handle "\"".${$data}{$ip_address}{'slot'}{$slot}{'main'}{'entPhysicalModelName'}."\"\n";
			for (my $bay=0;$bay< keys ( %{${$data}{$ip_address}{'slot'}{$slot}{'child'}} ); $bay++ )
				{
				if ( !${$data}{$ip_address}{'slot'}{$slot}{'child'}{$bay}{'entPhysicalDescr'} )
					{ ${$data}{$ip_address}{'slot'}{$slot}{'child'}{$bay}{'entPhysicalDescr'}="Empty"; }
				next unless ${$data}{$ip_address}{'slot'}{$slot}{'child'}{$bay}{'entPhysicalSerialNum'} ||
					${$data}{$ip_address}{'slot'}{$slot}{'child'}{$bay}{'entPhysicalDescr'}=~/^Empty/;
				print $handle "\"$ip_address\",\"${$router_list}{$ip_address}{'hostName'}\",\"$slot\",";
				print $handle "\"$bay\",\"".${$data}{$ip_address}{'slot'}{$slot}{'child'}{$bay}{'entPhysicalDescr'}."\",";
				print $handle "\"".${$data}{$ip_address}{'slot'}{$slot}{'child'}{$bay}{'entPhysicalSerialNum'}."\",";
				print $handle "\"".${$data}{$ip_address}{'slot'}{$slot}{'child'}{$bay}{'entPhysicalModelName'}."\"\n";
				}
			}
		}
	}

return 1;
}

sub Export_7500_Port_Inventory
{
my $self = shift;
my $data = shift;
my $router_list = shift;
my $handle = shift;
my $format = shift;

if ( scalar ( keys %{$data} ) == 0 )
        { $self->{_GLOBAL}{'STATUS'}="No Router Data Available."; return 0; }

if ( scalar ( keys %{$router_list} ) == 0 )
        { $self->{_GLOBAL}{'STATUS'}="Router List Required."; return 0; }

if ( !$handle )
        { $self->{_GLOBAL}{'STATUS'}="File Handle Required."; return 0; }

if ( $format!~/csv/i )
        { $self->{_GLOBAL}{'STATUS'}="Only CSV Format Supported."; return 0; }

if ( $format=~/csv/i )
        { print $handle "ip_address,hostname,slot,port,bay,interface_name,operstatus,adminstatus\n"; }

foreach my $ip_address ( keys %{$data} )
	{
	if ( $format=~/csv/i )
		{
		foreach my $interface ( keys %{${$data}{$ip_address}} )
			{
			my ($slot,$port,$bay);
			if ( ${$data}{$ip_address}{$interface}{'ifDescr'}=~/(\d+)$/ )
				{ $slot="$1"; $port="Main Controller"; $bay="None";  }
			if ( ${$data}{$ip_address}{$interface}{'ifDescr'}=~/(\d+)\/(\d+)\/(\d+)/ )
				{ $slot=$1; $port=$2; $bay=$3; }
			print $handle "\"$ip_address\",\"${$router_list}{$ip_address}{'hostName'}\",";
			print $handle "\"$slot\",\"$port\",\"$bay\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifDescr'}\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifOperStatus'}\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifAdminStatus'}\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifAlias'}\"";
			print $handle "\n";
			}
		}
	}
return 1;
}

sub Get_GSR_Inventory
{
my $self = shift;
my $data = shift;
my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }
my $snmp_variables = Router::Statistics::OID->Router_inventory_oid();

my %temp;

foreach my $ip_address ( keys %{$current_ubrs} )
	{
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table(
			-callback       => [ \&validate_one, \%temp, $ip_address, $snmp_variables ],
			-baseoid => ${$snmp_variables}{'PRIVATE_inventory'} );
	}
snmp_dispatcher();
foreach my $ip_address ( keys %temp )
	{
	foreach my $relative (  keys %{$temp{$ip_address}} )
		{
		next unless $temp{$ip_address}{$relative}{'entPhysicalName'}=~/^slot (\d+)/;
		$temp{$ip_address}{'rev'}{ $1 }=$relative;
		}
	foreach my $a ( keys %{$temp{$ip_address}{'rev'}} ) 
		{
		foreach my $attribute ( keys %{$snmp_variables} )
			{
			next if $attribute=~/PRIVATE/;
			${$data}{$ip_address}{'slot'}{$a}{$attribute}=
				$temp{$ip_address}{  $temp{$ip_address}{'rev'}{$a} }{$attribute};
			}
		}
	$temp{$ip_address}{'1'}{'entPhysicalDescr'}=~/^(\d+)\//;
	${$data}{$ip_address}{'total_slots'}=substr($1,3,2);
	}
undef %temp;
return 1;
}

sub Export_GSR_Slot_Inventory
{
my $self = shift;
my $data = shift;
my $router_list = shift;
my $handle = shift;
my $format = shift;

if ( scalar ( keys %{$data} ) == 0 )
	{ $self->{_GLOBAL}{'STATUS'}="No Router Data Available."; return 0; }

if ( scalar ( keys %{$router_list} ) == 0 )
	{ $self->{_GLOBAL}{'STATUS'}="Router List Required."; return 0; }

if ( !$handle )
	{ $self->{_GLOBAL}{'STATUS'}="File Handle Required."; return 0; }

if ( $format!~/csv/i )
	{ $self->{_GLOBAL}{'STATUS'}="Only CSV Format Supported."; return 0; }

if ( $format=~/csv/i )
	{ print $handle "ip_address,hostname,slot,description,serialnumber,partcode\n"; }

foreach my $ip_address ( keys %{$data} )
	{
	if ( $format=~/csv/i )
		{
		for(my $slot=0;$slot<${$data}{$ip_address}{'total_slots'};$slot++)
			{
			if ( !${$data}{$ip_address}{'slot'}{$slot}{'entPhysicalDescr'} )
				{ ${$data}{$ip_address}{'slot'}{$slot}{'entPhysicalDescr'}="Empty"; }
			print $handle "\"$ip_address\",\"${$router_list}{$ip_address}{'hostName'}\",\"$slot\",";
			print $handle "\"".${$data}{$ip_address}{'slot'}{$slot}{'entPhysicalDescr'}."\",";
			print $handle "\"".${$data}{$ip_address}{'slot'}{$slot}{'entPhysicalSerialNum'}."\",";
			print $handle "\"".${$data}{$ip_address}{'slot'}{$slot}{'entPhysicalModelName'}."\"\n";
			}
		}
	}
return 1;
}

sub Export_GSR_Port_Inventory
{
my $self = shift;
my $data = shift;
my $router_list = shift;
my $handle = shift;
my $format = shift;

if ( scalar ( keys %{$data} ) == 0 )
        { $self->{_GLOBAL}{'STATUS'}="No Router Data Available."; return 0; }

if ( scalar ( keys %{$router_list} ) == 0 )
        { $self->{_GLOBAL}{'STATUS'}="Router List Required."; return 0; }

if ( !$handle )
        { $self->{_GLOBAL}{'STATUS'}="File Handle Required."; return 0; }

if ( $format!~/csv/i )
        { $self->{_GLOBAL}{'STATUS'}="Only CSV Format Supported."; return 0; }

if ( $format=~/csv/i )
        { print $handle "ip_address,hostname,slot,port,interface_name,operstatus,adminstatus\n"; }

foreach my $ip_address ( keys %{$data} )
	{
	if ( $format=~/csv/i )
		{
		foreach my $interface ( keys %{${$data}{$ip_address}} )
			{
			my ($slot,$port);
			if ( ${$data}{$ip_address}{$interface}{'ifDescr'}=~/(\d+)$/ )
				{ $slot="$1"; $port="Main Controller"; }
			if ( ${$data}{$ip_address}{$interface}{'ifDescr'}=~/(\d+)\/(\d+)/ )
				{ $slot=$1; $port=$2; }
			print $handle "\"$ip_address\",\"${$router_list}{$ip_address}{'hostName'}\",";
			print $handle "\"$slot\",\"$port\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifDescr'}\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifOperStatus'}\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifAdminStatus'}\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifAlias'}\"";
			print $handle "\n";
			}
		}
	}
return 1;
}

sub Export_7600_Slot_Inventory
{
my $self = shift;
my $data = shift;
my $router_list = shift;
my $handle = shift;
my $format = shift;

if ( scalar ( keys %{$data} ) == 0 )
	{ $self->{_GLOBAL}{'STATUS'}="No Router Data Available."; return 0; }

if ( scalar ( keys %{$router_list} ) == 0 )
	{ $self->{_GLOBAL}{'STATUS'}="Router List Required."; return 0; }

if ( !$handle )
	{ $self->{_GLOBAL}{'STATUS'}="File Handle Required."; return 0; }

if ( $format!~/csv/i )
	{ $self->{_GLOBAL}{'STATUS'}="Only CSV Format Supported."; return 0; }

if ( $format=~/csv/i )
	{ print $handle "ip_address,hostname,slot,port,description,serialnumber,partcode\n"; }

foreach my $ip_address ( keys %{$data} )
        {
	if ( $format=~/csv/i )
		{
		for(my $slot=0;$slot<${$data}{$ip_address}{'total_slots'};$slot++)
			{
			if ( !${$data}{$ip_address}{'slot'}{$slot}{'main'}{'entPhysicalDescr'} )
				{ ${$data}{$ip_address}{'slot'}{$slot}{'main'}{'entPhysicalDescr'}="Empty"; }
			print $handle "\"$ip_address\",\"${$router_list}{$ip_address}{'hostName'}\",\"$slot\",";
			print $handle "\"Main\",\"".${$data}{$ip_address}{'slot'}{$slot}{'main'}{'entPhysicalDescr'}."\",";
			print $handle "\"".${$data}{$ip_address}{'slot'}{$slot}{'main'}{'entPhysicalSerialNum'}."\",";
			print $handle "\"".${$data}{$ip_address}{'slot'}{$slot}{'main'}{'entPhysicalModelName'}."\"\n";
			for (my $bay=1;$bay< keys ( %{${$data}{$ip_address}{'slot'}{$slot}{'child'}} )+1; $bay++ )
				{
				if ( !${$data}{$ip_address}{'slot'}{$slot}{'child'}{$bay}{'entPhysicalDescr'} )
					{ ${$data}{$ip_address}{'slot'}{$slot}{'child'}{$bay}{'entPhysicalDescr'}="Empty"; }
				print $handle "\"$ip_address\",\"${$router_list}{$ip_address}{'hostName'}\",\"$slot\",";
				print $handle "\"$bay\",\"".${$data}{$ip_address}{'slot'}{$slot}{'child'}{$bay}{'entPhysicalDescr'}."\",";
				print $handle "\"".${$data}{$ip_address}{'slot'}{$slot}{'child'}{$bay}{'entPhysicalSerialNum'}."\",";
				print $handle "\"".${$data}{$ip_address}{'slot'}{$slot}{'child'}{$bay}{'entPhysicalModelName'}."\"\n";
				}
			}
		}
	}
return 1;
}

sub Export_7600_Port_Inventory
{
my $self = shift;
my $data = shift;
my $router_list = shift;
my $handle = shift;
my $format = shift;

if ( scalar ( keys %{$data} ) == 0 )
	{ $self->{_GLOBAL}{'STATUS'}="No Router Data Available."; return 0; }

if ( scalar ( keys %{$router_list} ) == 0 )
	{ $self->{_GLOBAL}{'STATUS'}="Router List Required."; return 0; }

if ( !$handle )
	{ $self->{_GLOBAL}{'STATUS'}="File Handle Required."; return 0; }

if ( $format!~/csv/i )
	{ $self->{_GLOBAL}{'STATUS'}="Only CSV Format Supported."; return 0; }

if ( $format=~/csv/i )
	{ print $handle "ip_address,hostname,slot,port,description,operstatus,adminstatus\n"; }

foreach my $ip_address ( keys %{$data} )
        {
	if ( $format=~/csv/i )
		{
		foreach my $interface ( keys %{${$data}{$ip_address}} )
			{
			my ($slot,$port);
			if ( ${$data}{$ip_address}{$interface}{'ifDescr'}=~/(\d+)$/ )
				{ $slot="$1"; $port="Main Controller"; }
			if ( ${$data}{$ip_address}{$interface}{'ifDescr'}=~/(\d+)\/(\d+)/ )
				{ $slot=$1; $port=$2; }
			print $handle "\"$ip_address\",\"${$router_list}{$ip_address}{'hostName'}\",";
			print $handle "\"$slot\",\"$port\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifDescr'}\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifOperStatus'}\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifAdminStatus'}\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifAlias'}\"";
			print $handle "\n";
			}
		}
	}

return 1;
}


sub Get_UBR_Inventory
{
my $self = shift;
my $data = shift;
$self->UBR_7200_get_Inventory ( $data );
}

sub Get_UBR_Inventory_Blocking
{
my $self = shift;
my $data = shift;
$self->UBR_7200_get_Inventory_Blocking ( $data );
}

sub UBR_7200_get_Inventory
{
my $self = shift;
my $data = shift;
my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }
my $snmp_variables = Router::Statistics::OID->Router_inventory_oid();
my %temp;
foreach my $ip_address ( keys %{$current_ubrs} )
	{
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table(
			-callback       => [ \&validate_one, \%temp, $ip_address, $snmp_variables ],
			-baseoid => ${$snmp_variables}{'PRIVATE_inventory'} );
	}
snmp_dispatcher();
foreach my $ip_address ( keys %temp )
	{
	foreach my $relative (  keys %{$temp{$ip_address}} )
		{
		next unless $temp{$ip_address}{$relative}{'entPhysicalDescr'}=~/mc/i ||
			$temp{$ip_address}{$relative}{'entPhysicalDescr'}=~/ether/i;
		$temp{$ip_address}{'rev'}{ $temp{$ip_address}{$relative}{'entPhysicalParentRelPos'} }=
			$relative;
		}
	foreach my $a ( keys %{$temp{$ip_address}{'rev'}} ) 
		{
		foreach my $attribute ( keys %{$snmp_variables} )
			{
			next if $attribute=~/PRIVATE/;
			${$data}{$ip_address}{$a}{$attribute}=
				$temp{$ip_address}{  $temp{$ip_address}{'rev'}{$a} }{$attribute};
			}
		}
	${$data}{$ip_address}{'total_slots'}=6;
	}
undef %temp;
return 1;
}

sub UBR_7200_get_Inventory_Blocking
{
my $self = shift;
my $data = shift;
my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }
my $snmp_variables = Router::Statistics::OID->Router_inventory_oid();
my $int_snmp_variables = Router::Statistics::OID->Host_populate_oid();
my %temp;
my ($foo,$bar);
foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
        my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_table(
                        -baseoid => ${$snmp_variables}{'PRIVATE_inventory'} );

	while(($foo, $bar) = each(%{$profile_information}))
                { foreach my $snmp_value ( keys %{$snmp_variables} )
                        { if ( $foo=~/^${$snmp_variables}{$snmp_value}.(\d+)/ ) { $temp{$ip_address}{$1}{$snmp_value}=$bar; } }
                delete ${$profile_information}{$foo};
                }

	($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_request ( -varbindlist => [
				${$int_snmp_variables}{'sysDescr'},
				${$int_snmp_variables}{'entPhysicalDescr.1'},
				${$int_snmp_variables}{'entPhysicalDescr.2'},
				] );

	${$data}{$ip_address}{'ios_version'} =
		(split(/,/,$profile_information->{ ${$int_snmp_variables}{'sysDescr'} }))[1];
	${$data}{$ip_address}{'chassis'} =
		$profile_information->{ ${$int_snmp_variables}{'entPhysicalDescr.1'} };
	${$data}{$ip_address}{'cpu_type'} =
		$profile_information->{ ${$int_snmp_variables}{'entPhysicalDescr.2'} };

        }

foreach my $ip_address ( keys %temp )
        {
        foreach my $relative (  keys %{$temp{$ip_address}} )
                {
                next unless $temp{$ip_address}{$relative}{'entPhysicalDescr'}=~/mc/i ||
                        $temp{$ip_address}{$relative}{'entPhysicalDescr'}=~/ether/i;
                $temp{$ip_address}{'rev'}{ $temp{$ip_address}{$relative}{'entPhysicalParentRelPos'} }=
                        $relative;
                }
        foreach my $a ( keys %{$temp{$ip_address}{'rev'}} )
                {
                foreach my $attribute ( keys %{$snmp_variables} )
                        {
                        next if $attribute=~/PRIVATE/;
                        ${$data}{$ip_address}{$a}{$attribute}=
                                $temp{$ip_address}{  $temp{$ip_address}{'rev'}{$a} }{$attribute};
                        }
                }
        ${$data}{$ip_address}{'total_slots'}=6;
        }
undef %temp;
return 1;
}


sub Export_UBR_Slot_Inventory
{
my $self = shift;
my $data = shift;
my $router_list = shift;
my $handle = shift;
my $format = shift;

if ( scalar ( keys %{$data} ) == 0 )
	{ $self->{_GLOBAL}{'STATUS'}="No Router Data Available."; return 0; }

if ( scalar ( keys %{$router_list} ) == 0 )
	{ $self->{_GLOBAL}{'STATUS'}="Router List Required."; return 0; }

if ( !$handle )
	{ $self->{_GLOBAL}{'STATUS'}="File Handle Required."; return 0; }

if ( $format!~/csv/i )
	{ $self->{_GLOBAL}{'STATUS'}="Only CSV Format Supported."; return 0; }

if ( $format=~/csv/i )
	{ print $handle "ip_address,hostname,slot,description,serialnum,partcode\n"; }

foreach my $ip_address ( keys %{$data} )
        {
	if ( $format=~/csv/i )
		{
        	for(my $slot=0;$slot<${$data}{$ip_address}{'total_slots'}+1;$slot++)
                	{
                	if ( !${$data}{$ip_address}{$slot}{'entPhysicalDescr'} )
                	        { ${$data}{$ip_address}{$slot}{'entPhysicalDescr'}="Empty"; }
                	print $handle "\"$ip_address\",\"${$router_list}{$ip_address}{'hostName'}\",\"$slot\",";
                	print $handle "\"${$data}{$ip_address}{$slot}{'entPhysicalDescr'}\",";
                	print $handle "\"${$data}{$ip_address}{$slot}{'entPhysicalSerialNum'}\",";
			print $handle "\"${$data}{$ip_address}{$slot}{'entPhysicalModelName'}\"";	
			print $handle "\n";
                	}
        	}
	}
return 1;
}

sub Export_UBR_Port_Inventory
{
my $self = shift;
my $data = shift;
my $router_list = shift;
my $handle = shift;
my $format = shift;

if ( scalar ( keys %{$data} ) == 0 )
        { $self->{_GLOBAL}{'STATUS'}="No Router Data Available."; return 0; }

if ( scalar ( keys %{$router_list} ) == 0 )
        { $self->{_GLOBAL}{'STATUS'}="Router List Required."; return 0; }

if ( !$handle )
        { $self->{_GLOBAL}{'STATUS'}="File Handle Required."; return 0; }

if ( $format!~/csv/i )
        { $self->{_GLOBAL}{'STATUS'}="Only CSV Format Supported."; return 0; }

if ( $format=~/csv/i )
        { print $handle "ip_address,hostname,slot,port,interface_name,operstatus,adminstatus\n"; }

foreach my $ip_address ( keys %{$data} )
	{
	if ( $format=~/csv/i )
		{
		foreach my $interface ( keys %{${$data}{$ip_address}} )
			{
			my ($slot,$port);
			if ( ${$data}{$ip_address}{$interface}{'ifDescr'}=~/(\d+)$/ )
				{ $slot="$1"; $port="Main Controller"; }
			if ( ${$data}{$ip_address}{$interface}{'ifDescr'}=~/(\d+)\/(\d+)/ )
				{ $slot=$1; $port=$2; }
			print $handle "\"$ip_address\",\"${$router_list}{$ip_address}{'hostName'}\",";
			print $handle "\"$slot\",\"$port\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifDescr'}\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifOperStatus'}\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifAdminStatus'}\",";
			print $handle "\"${$data}{$ip_address}{$interface}{'ifAlias'}\"";
			print $handle "\n";
			}
		}
	}
return 1;
}

sub Get_7600_Inventory
{
my $self = shift;
my $data = shift;
my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }
my $snmp_variables = Router::Statistics::OID->Router_inventory_oid();

my %temp;

foreach my $ip_address ( keys %{$current_ubrs} )
	{
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table(
			-callback       => [ \&validate_one, \%temp, $ip_address, $snmp_variables ],
			-baseoid => ${$snmp_variables}{'PRIVATE_inventory'} );
	}
snmp_dispatcher();


foreach my $ip_address ( keys %temp )
        {
        foreach my $relative (  keys %{$temp{$ip_address}} )
                {
		if ( $temp{$ip_address}{$relative}{'entPhysicalName'}=~/^(\d+)$/ )
			{ $temp{$ip_address}{'rev'}{ $1 }{'main'}=$relative; }
                if ( $temp{$ip_address}{$relative}{'entPhysicalName'}=~/(\d+)\/(\d+)$/ )
                        { $temp{$ip_address}{'rev'}{ $1 }{'child'}{$2}=$relative; }
                }
        foreach my $a ( keys %{$temp{$ip_address}{'rev'}} )
                {
                foreach my $child ( keys %{$temp{$ip_address}{'rev'}{$a}{'child'}} )
                        {
                        foreach my $attribute ( keys %{$snmp_variables} )
                                {
                                next if $attribute=~/PRIVATE/;
                                ${$data}{$ip_address}{'slot'}{$a}{'child'}{$child}{$attribute}=
                                        $temp{$ip_address}{ $temp{$ip_address}{'rev'}{$a}{'child'}{$child} } {$attribute};
                                }
                        }
		foreach my $attribute ( keys %{$snmp_variables} )
			{
			next if $attribute=~/PRIVATE/;
			${$data}{$ip_address}{'slot'}{$a}{'main'}{$attribute}=
				$temp{$ip_address}{ $temp{$ip_address}{'rev'}{$a}{'main'} }{$attribute};
			}
                }
	$temp{$ip_address}{'1'}{'entPhysicalDescr'}=~/Cisco (\d+) (\d+)-slot/;
	${$data}{$ip_address}{'total_slots'}=$2;
        }
undef %temp;
return 1;
}

sub CMTS_get_DOCSIS_profiles
{
my $self = shift;
my $data = shift;
my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }
my $snmp_variables = Router::Statistics::OID->DOCSIS_Modulation();

my %temp;

foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
        my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
	get_table(
                -callback       => [ \&validate_two, $data, $ip_address, $snmp_variables ],
                -baseoid => ${$snmp_variables}{'PRIVATE_docsIfCmtsMod_base'} );
        }

foreach my $ip ( keys %{$data} )
        {
        foreach my $profile_id ( keys %{${$data}{$ip}} )
                {
                foreach my $attribute ( keys %{${$data}{$ip}{$profile_id}} )
                        {
                        if ( $attribute=~/docsIfCmtsModType/i )
                                {
                                ${$data}{$ip}{$profile_id}{$attribute}=
                                        ( '0_unknown' , '1_other', '2_qpsk', '3_qam16',
                                                '4_qam8', '5_qam32', '6_qam64', '7_qam128' )
                                                [${$data}{$ip}{$profile_id}{$attribute}];
                                }
                        if ( $attribute=~/docsIfCmtsModDifferentialEncoding/i )
                                {
                                ${$data}{$ip}{$profile_id}{$attribute}=
                                        ( '0_unknown', '1_true', '2_false' )
                                                [${$data}{$ip}{$profile_id}{$attribute}];
                                }
                        if ( $attribute=~/docsIfCmtsModLastCodewordShortened/i )
                                {
                                ${$data}{$ip}{$profile_id}{$attribute}=
                                        ( '0_unknown', '1_true', '2_false' )
                                                [${$data}{$ip}{$profile_id}{$attribute}];
                                }
                        if ( $attribute=~/docsIfCmtsModScrambler/i )
                                {
                                ${$data}{$ip}{$profile_id}{$attribute}=
                                        ( '0_unknown', '1_true', '2_false' )
                                                [${$data}{$ip}{$profile_id}{$attribute}];
                                }
                        if ( $attribute=~/docsIfCmtsModPreambleType/i )
                                {
                                ${$data}{$ip}{$profile_id}{$attribute}=
                                        ( '0_unknown', '1_qpsk0', '2_qpsk1' )
                                                [${$data}{$ip}{$profile_id}{$attribute}];
                                }
                        if ( $attribute=~/docsIfCmtsModTcmErrorCorrectionOn/i )
                                {
                                ${$data}{$ip}{$profile_id}{$attribute}=
                                        ( '0_unknown', '1_true', '2_false' )
                                                [${$data}{$ip}{$profile_id}{$attribute}];
                                }
                        if ( $attribute=~/docsIfCmtsModScdmaSpreaderEnable/i )
                                {
                                ${$data}{$ip}{$profile_id}{$attribute}=
                                        ( '0_unknown', '1_true', '2_false' )
                                                [${$data}{$ip}{$profile_id}{$attribute}];
                                }
                        if ( $attribute=~/docsIfCmtsModChannelType/i )
                                {
                                ${$data}{$ip}{$profile_id}{$attribute}=
                                        ( '0_unknown', '1_tdma', '2_atdma', '3_scdma','4_tdmaAndAtdma' )
                                                [${$data}{$ip}{$profile_id}{$attribute}];
                                }
                        }
                }
        }

snmp_dispatcher();
return 1;
}


sub UBR_get_DOCSIS_upstream_interfaces
{
my $self = shift;
my $data = shift;
# ie
#
# $result = $Object -> get_DOCSIS_upstream_interfaces ( \%upstream_interfaces );
#
# $result contains 1 or 0 for 1 = success, 0 = failure.

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
        {
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table(
			-callback       => [ \&validate_one, $data, $ip_address, $snmp_variables ],
			-baseoid => ${$snmp_variables}{'PRIVATE_cable_channel_information'} );
	}

snmp_dispatcher();

foreach my $ip_address ( keys %{$current_ubrs} )
	{
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table(
			-callback       => [ \&validate_one, $data, $ip_address, $snmp_variables ],
			-baseoid => ${$snmp_variables}{'PRIVATE_cable_channel_parameters'} );
	}
snmp_dispatcher();

return 1;
}

sub UBR_get_DOCSIS_upstream_interfaces_Blocking
{
my $self = shift;
my $data = shift;

my ( $foo, $bar );

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
        my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_table(
                        -baseoid => ${$snmp_variables}{'PRIVATE_cable_channel_information'} );
	while(($foo, $bar) = each(%{$profile_information}))
		{ foreach my $snmp_value ( keys %{$snmp_variables} )
			{ if ( $foo=~/^${$snmp_variables}{$snmp_value}.(\d+)/ ) { ${$data}{$ip_address}{$1}{$snmp_value}=$bar; } }
		delete ${$profile_information}{$foo};
		}

        ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_table(
                        -baseoid => ${$snmp_variables}{'PRIVATE_cable_channel_parameters'} );
	while(($foo, $bar) = each(%{$profile_information}))
		{ foreach my $snmp_value ( keys %{$snmp_variables} )
			{ if ( $foo=~/^${$snmp_variables}{$snmp_value}.(\d+)/ ) { ${$data}{$ip_address}{$1}{$snmp_value}=$bar; } }
		delete ${$profile_information}{$foo};
		}

        }
return 1;
}



sub UBR_get_DOCSIS_interface_information
{
my $self = shift;
my $data = shift;

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
        {
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table(
			-callback       => [ \&validate_one, $data, $ip_address, $snmp_variables ],
			-baseoid => ${$snmp_variables}{'PRIVATE_cable_signal_base'} );
	}
snmp_dispatcher();

return 1;
}

sub UBR_get_DOCSIS_interface_information_Blocking
{
my $self = shift;
my $data = shift;

my ( $foo, $bar );

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
        my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_table(
                        -baseoid => ${$snmp_variables}{'PRIVATE_cable_signal_base'} );
        while(($foo, $bar) = each(%{$profile_information}))
                { foreach my $snmp_value ( keys %{$snmp_variables} )
                        { if ( $foo=~/^${$snmp_variables}{$snmp_value}.(\d+)/ ) { ${$data}{$ip_address}{$1}{$snmp_value}=$bar; } }
                delete ${$profile_information}{$foo};
                }
        }

return 1;
}


sub UBR_get_DOCSIS_downstream_interfaces
{
my $self = shift;
my $data = shift;


my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
        {
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table(
			-callback       => [ \&validate_one, $data, $ip_address, $snmp_variables ],
			-baseoid => ${$snmp_variables}{'PRIVATE_downstream_interface'} );
	}

snmp_dispatcher();

foreach my $ip_address ( keys %{$current_ubrs} )
        {
        foreach my $interface ( keys %{${$data}{$ip_address}} )
                {
		${$data}{$ip_address}{$interface}{'docsIfDownChannelModulation'}=
			( '0_Down' , '1_Unknown', '2_other', '3_qam64', '4_qam256' )
			[${$data}{$ip_address}{$interface}{'docsIfDownChannelModulation'}];
                }
        }
return 1;
}

sub UBR_get_DOCSIS_downstream_interfaces_Blocking
{
my $self = shift;
my $data = shift;

my ( $foo, $bar );

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
        my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_table(
                        -baseoid => ${$snmp_variables}{'PRIVATE_downstream_interface'} );
        while(($foo, $bar) = each(%{$profile_information}))
                { foreach my $snmp_value ( keys %{$snmp_variables} )
                        { if ( $foo=~/^${$snmp_variables}{$snmp_value}.(\d+)/ ) { ${$data}{$ip_address}{$1}{$snmp_value}=$bar; } }
		delete ${$profile_information}{$foo};
		}
        }
foreach my $ip_address ( keys %{$current_ubrs} )
        {
        foreach my $interface ( keys %{${$data}{$ip_address}} )
                {
                ${$data}{$ip_address}{$interface}{'docsIfDownChannelModulation'}=
                        ( '0_Down', '1_Unknown', '2_other', '3_qam64', '4_qam256' )
                        [${$data}{$ip_address}{$interface}{'docsIfDownChannelModulation'}];
                }
        }
return 1;
}


sub UBR_get_active_upstream_profiles
{
my $self = shift;
my $data = shift;

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
	{
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table(
			-callback       => [ \&validate_one, $data, $ip_address, $snmp_variables ],
			-baseoid =>	${$snmp_variables}{'PRIVATE_docsIfCmtsModulationEntry'} );
	}
snmp_dispatcher();
foreach my $ip_address ( keys %{$current_ubrs} )
	{
	foreach my $profile ( keys %{${$data}{$ip_address}} )
		{
		foreach my $attribute ( keys %{${$data}{$ip_address}{$profile}} )
			{
        	        if ( $attribute=~/docsIfCmtsModType/ )
        	                { ${$data}{$ip_address}{$profile}{'docsIfCmtsModType'}=
        	                        (
					'Unknown',
					'other',
					'qpsk',
					'qam16',
					'qam8',
					'qam32',
					'qam64',
					'qam128'
					)
					[${$data}{$ip_address}{$profile}{'docsIfCmtsModType'}]; 
				}
			}
		}
	}
return 1;
}

sub UBR_get_active_upstream_profiles_Blocking
{
my $self = shift;
my $data = shift;

my ( $foo, $bar );

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
        {
        next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
        my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                get_table(
                        -baseoid =>     ${$snmp_variables}{'PRIVATE_docsIfCmtsModulationEntry'} );

        while(($foo, $bar) = each(%{$profile_information}))
                { foreach my $snmp_value ( keys %{$snmp_variables} )
                        { if ( $foo=~/^${$snmp_variables}{$snmp_value}.(\d+)/ ) { ${$data}{$ip_address}{$1}{$snmp_value}=$bar; } }
		delete ${$profile_information}{$foo};
		}
        }
foreach my $ip_address ( keys %{$current_ubrs} )
        {
        foreach my $profile ( keys %{${$data}{$ip_address}} )
                {
		${$data}{$ip_address}{$profile}{'docsIfCmtsModType'}=
			(
			'Unknown',
			'other',
			'qpsk',
			'qam16',
			'qam8',
			'qam32',
			'qam64',
			'qam128'
			) [${$data}{$ip_address}{$profile}{'docsIfCmtsModType'}];
                }
        }
return 1;
}


sub UBR_get_CPE_information_Blocking
{

my $self = shift;
my $data = shift;
my $data_selector = shift;

my ( $foo, $bar );

# Entry into the function is a point to a hash to store the data
# the result is a hash with the following

my (%rev_data_pack);
my (%other_addresses);

# This is where we get some information from the UBR about the CPEs connected
# This function should be modified so only the information needed is collected
# as you may not need it all, and on a busy UBR can take a while to return.

# Cisco Bug 1

# When snmp ifIndexPersist is configured, changing out MC16Cs, with MC28Us (
# or more than likely any other card ) causes some information to be 
# inaccessable using a standard get_table, so you have to fudge your way
# around the MIB tree

my ($check_loop);

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();


foreach my $ip_address ( keys %{$current_ubrs} )
        {
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	for ($check_loop=0;$check_loop<100;$check_loop++)
		{
		my $sider=${$snmp_variables}{'docsIfCmtsServiceCmStatusIndex'}.".".$check_loop;
		my ($status_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
        	        get_table( 
			-baseoid => $sider );
		while(($foo, $bar) = each(%{$status_information}))
			{
			if ( $foo=~/^${$snmp_variables}{'docsIfCmtsServiceCmStatusIndex'}.(\d+).(\d+)/ )
				{
				my $cmindexcode="$1:$2";
				$rev_data_pack{$ip_address}{$cmindexcode}=$bar;
				delete ${$status_information}{$foo};
				}
			}
		}
	}


if ( $data_selector=~/CPEIP/i || $data_selector=~/ALL/i )
        {
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		my ($status_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
			get_table(
			-baseoid => ${$snmp_variables}{'docsIfCmtsCmStatusIpAddress'} );
		while(($foo, $bar) = each(%{$status_information}))
			{
			if ( $foo=~/^${$snmp_variables}{'docsIfCmtsCmStatusIpAddress'}.(\d+)/ )
				{ ${$data}{$ip_address}{$1}{'docsIfCmtsCmStatusIpAddress'}=$bar; }
			delete ${$status_information}{$foo};
			}
		
		}
        }

if ( $data_selector=~/USERIP/i || $data_selector=~/ALL/i )
        {
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		my ($status_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
			get_table(
			-baseoid => ${$snmp_variables}{'cdxCmCpeIpAddress'} );
		while(($foo, $bar) = each(%{$status_information}))
			{
			if ( $foo=~/^${$snmp_variables}{'cdxCmCpeIpAddress'}.(\d+).(\d+).(\d+).(\d+).(\d+).(\d+)/ )
				{
				my $cmindexcode="$1:$2:$3:$4:$5:$6";
				$other_addresses{$cmindexcode}=$bar;
				}
			delete ${$status_information}{$foo};
			}
		}
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		my ($status_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
			get_table(
			-baseoid => ${$snmp_variables}{'cdxCmCpeCmStatusIndex'} );
		while(($foo, $bar) = each(%{$status_information}))
			{
			if ( $foo=~/^${$snmp_variables}{'cdxCmCpeCmStatusIndex'}.(\d+).(\d+).(\d+).(\d+).(\d+).(\d+)/ )
				{
				my $cmindexcode="$1:$2:$3:$4:$5:$6";
				${$data}{$ip_address}{$bar}{'cdxCmCpeCmStatusIndex'}=$cmindexcode;
				}
			delete ${$status_information}{$foo};
			}
		}
	}


if ( $data_selector=~/IFINDEX/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
			my ($status_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
				get_table( -baseoid => ${$snmp_variables}{'docsIfCmtsCmStatusUpChannelIfIndex'} );
			while(($foo, $bar) = each(%{$status_information}))
				{
				if ( $foo=~/^${$snmp_variables}{'docsIfCmtsCmStatusUpChannelIfIndex'}.(\d+)/ )
					{
					${$data}{$ip_address}{$1}{'docsIfCmtsCmStatusUpChannelIfIndex'}=$bar;
					}
				delete ${$status_information}{$foo};
			}
		}
	}

if ( $data_selector=~/QOSPROFILE/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		for ($check_loop=0;$check_loop<100;$check_loop++)
			{
			my $sider=${$snmp_variables}{'docsIfCmtsServiceQosProfile'}.".".$check_loop;
			my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
				get_table(
				-baseoid => $sider );
			while(($foo, $bar) = each(%{$status_information}))
				{
				if ( $foo=~/^${$snmp_variables}{'docsIfCmtsServiceQosProfile'}.(\d+).(\d+)/ )
					{
					my $cmindexcode="$1:$2";
					$cmindexcode=$rev_data_pack{$ip_address}{$cmindexcode};
					${$data}{$ip_address}{$cmindexcode}{'docsIfCmtsServiceQosProfile'}=$bar;
					}
				delete ${$status_information}{$foo};
				}
			}
		}
	}

if ( $data_selector=~/INOCTETS/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		for ($check_loop=0;$check_loop<100;$check_loop++)
			{
			my $sider=${$snmp_variables}{'docsIfCmtsServiceInOctets'}.".".$check_loop;
			my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
				get_table(
				-baseoid => $sider );
			while(($foo, $bar) = each(%{$status_information}))
				{
				if ( $foo=~/^${$snmp_variables}{'docsIfCmtsServiceInOctets'}.(\d+).(\d+)/ )
					{
					my $cmindexcode="$1:$2";
					$cmindexcode=$rev_data_pack{$ip_address}{$cmindexcode};
					${$data}{$ip_address}{$cmindexcode}{'docsIfCmtsServiceInOctets'}=$bar;
					}
				delete ${$status_information}{$foo};
				}
			}
		}
	}

if ( $data_selector=~/INPACKETS/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		for ($check_loop=0;$check_loop<100;$check_loop++)
			{
			my $sider=${$snmp_variables}{'docsIfCmtsServiceInPackets'}.".".$check_loop;
			my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
				get_table(
				-baseoid => $sider );
			while(($foo, $bar) = each(%{$status_information}))
				{
				if ( $foo=~/^${$snmp_variables}{'docsIfCmtsServiceInPackets'}.(\d+).(\d+)/ )
					{
					my $cmindexcode="$1:$2";
					$cmindexcode=$rev_data_pack{$ip_address}{$cmindexcode};
					${$data}{$ip_address}{$cmindexcode}{'docsIfCmtsServiceInPackets'}=$bar;
					}
				delete ${$status_information}{$foo};
				}
			}
		}
        }


if ( $data_selector=~/OUTOCTETS/i || $data_selector=~/ALL/i )
        {
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		for ($check_loop=0;$check_loop<100;$check_loop++)
			{
			my $sider=${$snmp_variables}{'cdxIfCmtsServiceOutOctets'}.".".$check_loop;
			my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
				get_table(
				-baseoid => $sider );
			while(($foo, $bar) = each(%{$status_information}))
				{
				if ( $foo=~/^${$snmp_variables}{'cdxIfCmtsServiceOutOctets'}.(\d+).(\d+)/ )
					{
					my $cmindexcode="$1:$2";
					$cmindexcode=$rev_data_pack{$ip_address}{$cmindexcode};
					${$data}{$ip_address}{$cmindexcode}{'cdxIfCmtsServiceOutOctets'}=$bar;
					}
				delete ${$status_information}{$foo};
				}
			}
		}
	}

if ( $data_selector=~/OUTPACKETS/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		for ($check_loop=0;$check_loop<100;$check_loop++)
			{
			my $sider=${$snmp_variables}{'cdxIfCmtsServiceOutPackets'}.".".$check_loop;
			my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
				get_table(
				-baseoid => $sider );
			while(($foo, $bar) = each(%{$status_information}))
				{
				if ( $foo=~/^${$snmp_variables}{'cdxIfCmtsServiceOutPackets'}.(\d+).(\d+)/ )
					{
					my $cmindexcode="$1:$2";
					$cmindexcode=$rev_data_pack{$ip_address}{$cmindexcode};
					${$data}{$ip_address}{$cmindexcode}{'cdxIfCmtsServiceOutPackets'}=$bar;
					}
				delete ${$status_information}{$foo};
				}
			}
		}
	}

if ( $data_selector=~/CPEMAC/i || $data_selector=~/ALL/i )
        {
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
			get_table(
			-baseoid => ${$snmp_variables}{'docsIfCmtsCmStatusMacAddress'} );
		while(($foo, $bar) = each(%{$status_information}))
			{
			if ( $foo=~/^${$snmp_variables}{'docsIfCmtsCmStatusMacAddress'}.(\d+)/ )
				{
				${$data}{$ip_address}{$1}{'docsIfCmtsCmStatusMacAddress'}=_convert_mac_address($bar);
				}
			delete ${$status_information}{$foo};
			}
		}
	}

if ( $data_selector=~/STATUS/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
			get_table(
			-baseoid => ${$snmp_variables}{'docsIfCmtsCmStatusValue'} );
		while(($foo, $bar) = each(%{$status_information}))
			{
			if ( $foo=~/^${$snmp_variables}{'docsIfCmtsCmStatusValue'}.(\d+)/ )
				{
				${$data}{$ip_address}{$1}{'docsIfCmtsCmStatusValue'}=
						(
						'0_Unknown',
						'1_other',
						'2_ranging',
						'3_rangingAborted',
						'4_rangingComplete',
						'5_ipComplete',
						'6_registrationComplete',
						'7_accessDenied',
						'8_operational (older IOS)',
						'9_registeredBPIInitializing')
						[$bar];
				}
			delete ${$status_information}{$foo};
			}
		}
	}
return 1;
}


sub UBR_get_CPE_information
{

my $self = shift;
my $data = shift;
my $data_selector = shift;

# Entry into the function is a point to a hash to store the data
# the result is a hash with the following

my ($foo, $bar );
my (%rev_data_pack);
my (%other_addresses);

# This is where we get some information from the UBR about the CPEs connected
# This function should be modified so only the information needed is collected
# as you may not need it all, and on a busy UBR can take a while to return.

# Cisco Bug 1

# When snmp ifIndexPersist is configured, changing out MC16Cs, with MC28Us (
# or more than likely any other card ) causes some information to be 
# inaccessable using a standard get_table, so you have to fudge your way
# around the MIB tree

my ($check_loop);

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();


foreach my $ip_address ( keys %{$current_ubrs} )
        {
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	for ($check_loop=0;$check_loop<100;$check_loop++)
		{
		my $sider=${$snmp_variables}{'docsIfCmtsServiceCmStatusIndex'}.".".$check_loop;
		my ($status_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
        	        get_table( 
			-callback       => [ \&validate_two_rev, \%rev_data_pack, $ip_address, $snmp_variables ],
			-baseoid => $sider );
		}
	}
snmp_dispatcher();

if ( $data_selector=~/CPEIP/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		my ($status_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
			get_table( 
			-callback       => [ \&validate_one, $data, $ip_address, $snmp_variables ],
			-baseoid => ${$snmp_variables}{'docsIfCmtsCmStatusIpAddress'} );
		}
	snmp_dispatcher();
	}

if ( $data_selector=~/USERIP/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		my ($status_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
        	    get_table( 
			-callback       => [ \&validate_two, \%other_addresses, $ip_address, $snmp_variables ],
			-baseoid => ${$snmp_variables}{'cdxCmCpeIpAddress'} );
		}
	snmp_dispatcher();
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		my ($status_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
	            get_table( 
			-callback       => [ \&validate_two, $data, $ip_address,$snmp_variables ],
			-baseoid => ${$snmp_variables}{'cdxCmCpeCmStatusIndex'} );
		}
	snmp_dispatcher();
	foreach my $cpe ( keys %{$data} ) { chop ( ${$data}{$cpe}->{'cdxCmCpeIpAddress'} ); }
	}

if ( $data_selector=~/IFINDEX/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		my ($status_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
        	    get_table( 
			-callback       => [ \&validate_one, $data, $ip_address, $snmp_variables ],
			-baseoid => ${$snmp_variables}{'docsIfCmtsCmStatusUpChannelIfIndex'} );
		}
	snmp_dispatcher();
	}

if ( $data_selector=~/QOSPROFILE/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		for ($check_loop=0;$check_loop<50;$check_loop++)
			{
			my $sider=${$snmp_variables}{'docsIfCmtsServiceQosProfile'}.".".$check_loop;
			my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
				get_table( 
					-callback       => [ \&validate_two_special, $data, $ip_address, $snmp_variables, \%rev_data_pack ],
					-baseoid => $sider );
			}
		}
	snmp_dispatcher();
	}

if ( $data_selector=~/INOCTETS/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		for ($check_loop=0;$check_loop<100;$check_loop++)
			{
			my $sider=${$snmp_variables}{'docsIfCmtsServiceInOctets'}.".".$check_loop;
			my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
				get_table( 
					-callback       => [ \&validate_two_special, $data, $ip_address, $snmp_variables, \%rev_data_pack ],
					-baseoid => $sider );
			}
		}
	snmp_dispatcher();
	}

if ( $data_selector=~/INPACKETS/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		for ($check_loop=0;$check_loop<100;$check_loop++)
			{
			my $sider=${$snmp_variables}{'docsIfCmtsServiceInPackets'}.".".$check_loop;
			my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
				get_table( 
					-callback       => [ \&validate_two_special, $data, $ip_address, $snmp_variables, \%rev_data_pack ],
					-baseoid => $sider );
			}
		}
	snmp_dispatcher();
	}

if ( $data_selector=~/OUTOCTETS/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		for ($check_loop=0;$check_loop<100;$check_loop++)
			{
			my $sider=${$snmp_variables}{'cdxIfCmtsServiceOutOctets'}.".".$check_loop;
			my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
				get_table( 
					-callback       => [ \&validate_two_special, $data, $ip_address, $snmp_variables, \%rev_data_pack ],
					-baseoid => $sider );
			}
		}
	snmp_dispatcher();
	}

if ( $data_selector=~/OUTPACKETS/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		for ($check_loop=0;$check_loop<100;$check_loop++)
			{
			my $sider=${$snmp_variables}{'cdxIfCmtsServiceOutPackets'}.".".$check_loop;
			my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
				get_table( 
					-callback       => [ \&validate_two_special, $data, $ip_address, $snmp_variables, \%rev_data_pack ],
					-baseoid => $sider );
			}
		}
	snmp_dispatcher();
	}

if ( $data_selector=~/CPEMAC/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
			get_table( 
				-callback       => [ \&validate_one, $data, $ip_address, $snmp_variables ],
				-baseoid => ${$snmp_variables}{'docsIfCmtsCmStatusMacAddress'} );
		}
	snmp_dispatcher();
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		foreach my $cpe ( keys %{${$data}{$ip_address}} )
			{
			${$data}{$ip_address}{$cpe}{'docsIfCmtsCmStatusMacAddress'}=
				_convert_mac_address( ${$data}{$ip_address}{$cpe}{'docsIfCmtsCmStatusMacAddress'} );
			}
		}
	}

if ( $data_selector=~/STATUS/i || $data_selector=~/ALL/i )
	{
	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
		my ($status_information) = $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table( 
			-callback       => [ \&validate_one, $data, $ip_address, $snmp_variables ],
			-baseoid => ${$snmp_variables}{'docsIfCmtsCmStatusValue'} );
		}
	snmp_dispatcher();

	foreach my $ip_address ( keys %{$current_ubrs} )
		{
		foreach my $cpe ( keys %{${$data}{$ip_address}} )
			{
			${$data}{$ip_address}{$cpe}{'docsIfCmtsCmStatusValue'}=
				(
			'0_Unknown',
			'1_other',
			'2_ranging',
			'3_rangingAborted',
			'4_rangingComplete',
			'5_ipComplete',
			'6_registrationComplete',
			'7_accessDenied',
			'8_operational (older IOS)',
			'9_registeredBPIInitializing')
			[${$data}{$ip_address}{$cpe}{'docsIfCmtsCmStatusValue'}];
			}
		}
	}

undef %other_addresses;
undef %rev_data_pack;

if ( scalar ( keys %{$data} ) == 0 )
        { $self->{_GLOBAL}{'STATUS'}="No UBR CPE Information Data Found.\n"; return 0; }

return 1;
}

sub UBR_modify_cpe_DOCSIS_profile
{
my $self = shift;
my $ip_address = shift;
my $profiles = shift;
my $profile_change = shift;
my $cpe_information = shift;
my $mac_to_change = shift;

if (!$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'})
        { $self->{_GLOBAL}{'STATUS'}="UBR Not Ready"; return 0; }

if ( !$profiles )
	{ $self->{_GLOBAL}{'STATUS'}="No Profiles Found"; return 0; }

if ( !$cpe_information )
	{ $self->{_GLOBAL}{'STATUS'}="No CPE Device Information Found"; return 0; }

if ( !$mac_to_change )
	{ $self->{_GLOBAL}{'STATUS'}="No MAC Address Specified"; return 0; }

if ( !$profile_change )
	{ $self->{_GLOBAL}{'STATUS'}="No Profile Specified"; return 0; }

my (@profile_definition) = split(/\//,$profile_change);

if ( scalar ( @profile_definition ) !=2 )
	{ $self->{_GLOBAL}{'STATUS'}="Profile Incorrect format ( upstream/downstream )"; return 0; }

my ($lock_profile)=0;
foreach my $profile ( %{${$profiles}{$ip_address}} )
	{
	my $merge = ${$profiles}{$ip_address}{$profile}{'docsIfQosProfMaxUpBandwidth'}."/".${$profiles}{$ip_address}{$profile}{'docsIfQosProfMaxDownBandwidth'};
	if ( $merge=~/^$profile_change$/ )
		{ $lock_profile=1; $profile_change=$profile; }
	}

if ( !$lock_profile )
	{ $self->{_GLOBAL}{'STATUS'}="Profile Specified Is Not Currently Configured"; return 0; }

($lock_profile)=0;
foreach my $mac_find ( keys %{${$cpe_information}{$ip_address}} )
	{
	if ( ${$cpe_information}{$ip_address}{$mac_find}{'docsIfCmtsCmStatusMacAddress'}=~/^$mac_to_change$/i )
		{
		$lock_profile=1;
		$mac_to_change=$mac_find;
		}
	}
if ( !$lock_profile )
	{ $self->{_GLOBAL}{'STATUS'}="MAC Specified Is Not Currently Online"; return 0; }

my @snmp_array;
my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();

push @snmp_array, ( ${$snmp_variables}{'cdxCmtsCmCurrQoSPro'}.".$mac_to_change" , INTEGER, $profile_change );
my ($reset)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
                        set_request( 
				-callback       => [ \&validate_one, {} , {} ],
				-varbindlist => [@snmp_array] );
snmp_dispatcher();

undef $snmp_variables;
undef @snmp_array;
undef $mac_to_change;
undef $profile_change;
undef $reset;

if ( $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->error )
        { $self->{_GLOBAL}{'STATUS'}=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->error; return 0; }

return 1;
}

sub UBR_reset_cpe_device
{
my $self = shift;
my $ip_address = shift;
my $mac_address = shift;

if (!$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'})
	{
	$self->{_GLOBAL}{'STATUS'}="UBR Not Ready"; return 0;
	}

my @mac_split=split(/\./,$mac_address);
my $index;
if ( scalar(@mac_split)==6 )
	{ foreach my $octet (@mac_split) { $index.=oct("0x$octet")."."; } chop($index); }

if ( scalar(@mac_split)==3 )
	{ foreach my $octet (@mac_split)
		{ my $first=substr($octet,0,2); my $second=substr($octet,2,2); 
		$index.=oct("0x$first")."."; $index.=oct("0x$second")."."; 	
		} chop($index);
	}
undef @mac_split;

if ( !$index )
	{ undef $index; $self->{_GLOBAL}{'STATUS'}="Incorrect MAC address format"; return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();
my @snmp_array;
push @snmp_array, ( ${$snmp_variables}{'cdxCmCpeResetNow'}.".$index" , INTEGER, 1 );
my ($reset)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
			set_request( 
				-callback       => [ \&validate_one, {} , {} ],
				-varbindlist => [@snmp_array] );
snmp_dispatcher();
undef @snmp_array;
undef $index;

if ( $self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->error )
	{ $self->{_GLOBAL}{'STATUS'}=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->error; return 0; }
return 1;
}



sub UBR_get_active_cpe_profiles
{
my $self = shift;
my $data = shift;

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
        {
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table( 
			-callback       => [ \&validate_one, $data, $ip_address, $snmp_variables ],
			-baseoid => ${$snmp_variables}{'PRIVATE_docs_profile_main'} );
	}
snmp_dispatcher();
return 1;
}

sub UBR_get_active_cpe_profiles_Blocking
{
my $self = shift;
my $data = shift;

my ( $foo, $bar );

my $current_ubrs=$self->Router_Return_All();
if ( scalar( keys %{$current_ubrs})==0 ) { return 0; }

my $snmp_variables = Router::Statistics::OID->DOCSIS_populate_oid();
foreach my $ip_address ( keys %{$current_ubrs} )
        {
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my ($profile_information)=$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_table( 
			-baseoid => ${$snmp_variables}{'PRIVATE_docs_profile_main'} );
	while(($foo, $bar) = each(%{$profile_information})) 
		{
		#next unless($foo =~ /^${$snmp_variables}{'PRIVATE_docs_profile_main'}.(\d+).(\d+)/);
		if ( $foo=~/^${$snmp_variables}{'docsIfQosProfPriority'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'docsIfQosProfPriority'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'docsIfQosProfMaxDownBandwidth'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'docsIfQosProfMaxDownBandwidth'}=$bar; }
		if ( $foo=~/^${$snmp_variables}{'docsIfQosProfMaxUpBandwidth'}.(\d+)/ )
			{ ${$data}{$ip_address}{$1}{'docsIfQosProfMaxUpBandwidth'}=$bar; }
		delete ${$profile_information}{$foo};
		}
	}
return 1;
}

sub get_CPE_info_dead
{
my $self = shift;
my $ip_address = shift;

my $snmp_variables = Router::Statistics::OID->CPE_populate_oid();

if (!$self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'})
	{ return 1; }

my $get_info = $self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'}
		->get_request
			(
			-varbindlist => [ ${$snmp_variables}{'sysDescr'} ] );
undef $snmp_variables;
return 1;
}

sub Router_Test_Connection
{
my $self = shift;
my $data = shift;

my $current_ubrs=$self->Router_Return_All();

my $snmp_variables = Router::Statistics::OID->Host_populate_oid();

foreach my $ip_address ( keys %{$current_ubrs} )
	{
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my $result = 
	$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_request( 
			-callback 	=> [ \&validate_callback, $ip_address, $data, $snmp_variables ],
			-varbindlist => [ 
				${$snmp_variables}{'sysUpTime'},
				${$snmp_variables}{'hostName'},
				${$snmp_variables}{'sysDescr'} ]);
	}
snmp_dispatcher();

foreach my $ip_address ( keys %{$current_ubrs} )
	{
	if ( !${$data}{$ip_address}{'sysUpTime'} ) 
		{ 
		$self->Router_Remove($ip_address); 
		} 
	}

return 1;
}

sub Router_Test_Connection_Blocking
{
my $self = shift;
my $data = shift;

my $current_ubrs=$self->Router_Return_All();

my $snmp_variables = Router::Statistics::OID->Host_populate_oid();

foreach my $ip_address ( keys %{$current_ubrs} )
	{
	next if !$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'};
	my $result = 
	$self->{_GLOBAL}{'Router'}{$ip_address}{'SESSION'}->
		get_request( 
			-varbindlist => [ 
				${$snmp_variables}{'sysUpTime'},
				${$snmp_variables}{'hostName'},
				${$snmp_variables}{'sysDescr'} ]);

	if ( $result->{${$snmp_variables}{'sysUpTime'}} )
		{
		${$data}{$ip_address}{'sysUpTime'}=$result->{${$snmp_variables}{'sysUpTime'}};
		${$data}{$ip_address}{'hostName'}=$result->{${$snmp_variables}{'hostName'}};
		${$data}{$ip_address}{'sysDescr'}=$result->{${$snmp_variables}{'sysDescr'}};
		}
		else
		{
		$self->Router_Remove($ip_address);
		}
	}
return 1;
}

sub CPE_Test_Connection
{
my $self = shift;
my $data = shift;
my $current_cpes = $self->CPE_Return_All();

my $snmp_variables = Router::Statistics::OID->Host_populate_oid();
foreach my $ip_address ( keys %{$current_cpes} )
        {
	print "IP is '$ip_address' session is '".$self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'}."'\n" 
			if $self->{_GLOBAL}{'DEBUG'}==1;
        next if !$self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'};
	print "First pass of '$ip_address'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
        $self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'}->
                get_request(
                        -callback       => [ \&validate_callback, $ip_address, $data, $snmp_variables ],
                        -varbindlist => [ ${$snmp_variables}{'sysUpTime'} ]);
	if  ( $self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'}->error )
		{
		print "Error was '".$self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'}->error."'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
		}
        }
snmp_dispatcher();
# We have done all the first keys in one go, so we should be left with devices that either have
# had two (or more) keys specified or none left.
foreach my $ip_address ( keys %{$current_cpes} )
        {
	print "Now we are here , so '$ip_address' uptime '${$data}{$ip_address}{'sysUpTime'}' keys '".$self->{_GLOBAL}{'CPE'}{$ip_address}{'keys_to_test'}."'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
        while ( !${$data}{$ip_address}{'sysUpTime'} && $self->{_GLOBAL}{'CPE'}{$ip_address}{'keys_to_test'} )
                {
		print "No uptime for '$ip_address' but we appear to have keys '".$self->{_GLOBAL}{'CPE'}{$ip_address}{'keys'}."'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
		$self->{_GLOBAL}{'CPE'}{$ip_address}{'key'}=
			(split(/,/,$self->{_GLOBAL}{'CPE'}{$ip_address}{'keys_to_test'}))[0];
		$self->{_GLOBAL}{'CPE'}{$ip_address}{'keys_to_test'}=join(',',
			(split(/,/,$self->{_GLOBAL}{'CPE'}{$ip_address}{'keys_to_test'}))[1,2,3,4,5,6,7,8,9,10]);

		print "Next key is '".$self->{_GLOBAL}{'CPE'}{$ip_address}{'key'}."'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
		print "Left key is '".$self->{_GLOBAL}{'CPE'}{$ip_address}{'keys_to_test'}."'\n" if $self->{_GLOBAL}{'DEBUG'}==1;

               	$self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'}->close();
               	$self->CPE_Ready ( $ip_address );
                if ( $self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'} )
       	                {
			print "Attempting check again for '$ip_address'\n" if $self->{_GLOBAL}{'DEBUG'}==1;
       	                $self->{_GLOBAL}{'CPE'}{$ip_address}{'SESSION'}->
       	                        get_request(
       	                                -callback       => [ \&validate_callback, $ip_address, $data, $snmp_variables ],
       	                                -varbindlist => [ ${$snmp_variables}{'sysUpTime'} ] );
			snmp_dispatcher();
                        }
                }
        }
snmp_dispatcher();
foreach my $ip_address ( keys %{$current_cpes} )
        {
        if ( !${$data}{$ip_address}{'sysUpTime'} )
                {
		print "Removing the CPE '$ip_address' no valid key found\n" if $self->{_GLOBAL}{'DEBUG'}==1;
                $self->CPE_Remove($ip_address);
                }
        }

return 1;
}

sub set_format
{
my $self = shift;
my $data = shift;
if ( !$data )
	{ $data="<year> <MonName> <day> <HH>:<MM>:<SS>"; }
$self->{_GLOBAL}{'DATETIME_FORMAT'}=$data;
return 1;
}

sub get_format
{
my $self = shift;
return $self->{_GLOBAL}{'DATETIME_FORMAT'};
}

sub convert_ntp_time_mask
{
my $self = shift;
my $raw_input = shift;
my $data = shift;
my $ip_address = shift;
my ( $time_ticks, $resolution ) = unpack ('NN', $raw_input );
$time_ticks -= 2208988800;
my $gm = localtime($time_ticks);
my $time = sprintf("%.2d:%.2d",$gm->hour(),$gm->min());
${$data}{$ip_address}{'time'}{'hour'}=sprintf("%.2d",$gm->hour());
${$data}{$ip_address}{'time'}{'min'}=sprintf("%.2d",$gm->min());
${$data}{$ip_address}{'time'}{'epoch'}=$time_ticks;
${$data}{$ip_address}{'time'}{'full_time'}=$time;
return 1;
}

sub convert_time_mask
{
my $self = shift;
my $raw_input = shift;
my $format = $self->get_format();
my ( $char1, $char2, $char3, $char4, $char5, $char6, $char7, $char8, $char9, $char10) = unpack ('nCCCCCCCCC', $raw_input);
my $month_name = ( 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')[ $char2-1 ];

my $month = sprintf("%.2d",$char2);
my $year = sprintf("%.4d",$char1);
my $day = sprintf("%.2d",$char3);
my $hour = sprintf("%.2d",$char4);
my $minute = sprintf("%.2d",$char5);
my $second = sprintf("%.2d",$char6);

$format =~s/\<year\>/$year/ig;
$format =~s/\<MonName\>/$month_name/ig;
$format =~s/\<Mon\>/$month/ig;
$format =~s/\<day\>/$day/ig;

$format =~s/\<HH\>/$hour/ig;
$format =~s/\<MM\>/$minute/ig;
$format =~s/\<SS\>/$second/ig;

return ( $format );
}


sub _convert_mac_address
{
my ($raw_input)=@_;
my ( $char1, $char2, $char3, $char4, $char5, $char6) = unpack ('CCCCCC', $raw_input);
$char1=sprintf ("%#.2x",$char1); $char1=(split(/0x/,$char1))[1] if $char1=~/x/g;
$char2=sprintf ("%#.2x",$char2); $char2=(split(/0x/,$char2))[1] if $char2=~/x/g;
$char3=sprintf ("%#.2x",$char3); $char3=(split(/0x/,$char3))[1] if $char3=~/x/g;
$char4=sprintf ("%#.2x",$char4); $char4=(split(/0x/,$char4))[1] if $char4=~/x/g;
$char5=sprintf ("%#.2x",$char5); $char5=(split(/0x/,$char5))[1] if $char5=~/x/g;
$char6=sprintf ("%#.2x",$char6); $char6=(split(/0x/,$char6))[1] if $char6=~/x/g;
return ("$char1$char2.$char3$char4.$char5$char6");
}

sub validate_callback
{
my ($session, $ip_address, $table, $snmp_variables ) = @_;
foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list})))
        {
	foreach my $attribute ( keys %{$snmp_variables} )
		{
		next if $attribute=~/^PRIVATE/;
		if ( $oid =~ /^${$snmp_variables}{$attribute}/)
			{
			${$table}{$ip_address}{$attribute}=$session->var_bind_list->{$oid}; }
			}
	delete ( $session->var_bind_list->{$oid} );
	}
return 1;
}

sub validate_one
{

my ($session, $table, $ip_address, $snmp_variables ) = @_;
foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) 
	{ 
        foreach my $attribute ( keys %{$snmp_variables} )
                {
                next if $attribute=~/^PRIVATE/;
                if ( $oid =~ /^${$snmp_variables}{$attribute}.(\d+)/)
                        {
			${$table}{$ip_address}{$1}{$attribute}=$session->var_bind_list->{$oid}; 
			}
                }
	delete ( $session->var_bind_list->{$oid} );
	}
	
return 1;
}

sub validate_one_cpe
{

my ($session, $table, $ip_address, $snmp_variables ) = @_;
foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) 
	{ 
        foreach my $attribute ( keys %{$snmp_variables} )
                {
                next if $attribute=~/^PRIVATE/;
                if ( $oid =~ /^${$snmp_variables}{$attribute}.(\d+)/)
                        {
			${$table}{$ip_address}{$attribute}=$session->var_bind_list->{$oid}; 
			}
                }
	delete ( $session->var_bind_list->{$oid} );
	}
	
return 1;
}

sub validate_two
{

my ($session, $table, $snmp_variables, $rev_data_pack ) = @_;
foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) 
	{ 
        foreach my $attribute ( keys %{$snmp_variables} )
                {
                next if $attribute=~/^PRIVATE/;
                if ( $oid =~ /^${$snmp_variables}{$attribute}.(\d+).(\d+)/)
                        { 
			my $cmindexcode="$1:$2";
			${$table}{$cmindexcode}{$attribute}=$session->var_bind_list->{$oid}; 
			}
                }
	delete ( $session->var_bind_list->{$oid} );
	}
	
return 1;
}

sub validate_two_rev
{

my ($session, $table, $ip_address, $snmp_variables ) = @_;
foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) 
	{ 
                if ( $oid =~ /^${$snmp_variables}{'docsIfCmtsServiceCmStatusIndex'}.(\d+).(\d+)/)
                        { 
			my $cmindexcode="$1:$2";
			${$table}{$ip_address}{$cmindexcode}=$session->var_bind_list->{$oid}; 
			}
	delete ( $session->var_bind_list->{$oid} );
	}
	
return 1;
}

sub validate_two_special
{

my ($session, $table, $ip_address, $snmp_variables, $rev_data_pack ) = @_;
foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) 
	{ 
        foreach my $attribute ( keys %{$snmp_variables} )
                {
                next if $attribute=~/^PRIVATE/;
                if ( $oid =~ /^${$snmp_variables}{$attribute}.(\d+).(\d+)/)
                        { 
			my $cmindexcode="$1:$2";  
			$cmindexcode=${$rev_data_pack}{$ip_address}{$cmindexcode};
			${$table}{$ip_address}{$cmindexcode}{$attribute}=$session->var_bind_list->{$oid}; 
			}
                }
	delete ( $session->var_bind_list->{$oid} );
	}
	
return 1;
}

sub validate_rule_base
{
my ($session, $table, $ip_address, $snmp_variables ) = @_;
foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list})))
        {
        foreach my $attribute ( keys %{$snmp_variables} )
                {
                next if $attribute=~/^PRIVATE/;
                if ( $oid =~ /^${$snmp_variables}{$attribute}\./)
                        {
			my $new_oid=$oid;
			$new_oid=~s/${$snmp_variables}{$attribute}//g;
			#print "New oid is '$new_oid'\n";
			#print "New oid is '$new_oid' value is '".$session->var_bind_list->{$oid}."'\n";
			my $name;
			foreach my $character ( split(/\./,$new_oid) )
				{ next if $character<15; $name.=chr($character); }
			$name=~s/^\s*//; $name=~ s/\s*$//;
			#print "Name is '$name'\n";
                        ${$table}{$ip_address}{'stm_rule_set'}{$name}{$attribute}=$session->var_bind_list->{$oid};
#			${$table}{$ip_address}{'name'}=$name;
                        }
                }
        delete ( $session->var_bind_list->{$oid} );
        }
return 1;
}


sub validate_two_plain
{

my ($session, $table, $ip_address, $snmp_variables, $rev_data_pack ) = @_;
foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list})))
        {
	foreach my $attribute ( keys %{$snmp_variables} )
		{
		next if $attribute=~/^PRIVATE/;
		if ( $oid =~ /^${$snmp_variables}{$attribute}.(\d+).(\d+)/)
			{
			my $cmindexcode="$1:$2";
			${$table}{$ip_address}{$cmindexcode}{$attribute}=$session->var_bind_list->{$oid};
			}
		}
	delete ( $session->var_bind_list->{$oid} );
	}
return 1;
}


sub validate_six
{
my ($session, $table, $snmp_variables ) = @_;
foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) 
	{ 
        foreach my $attribute ( keys %{$snmp_variables} )
                {
                next if $attribute=~/^PRIVATE/;
                if ( $oid =~ /^${$snmp_variables}{$attribute}.(\d+).(\d+).(\d+).(\d+).(\d+).(\d+)/)
                        { 
                	my $cmindexcode="$1.$2.$3.$4.$5.$6";
			${$table}{$cmindexcode}{$attribute}=$session->var_bind_list->{$oid}; 
			}
                }
	delete ( $session->var_bind_list->{$oid} );
	}
	
return 1;
}

sub validate_six_net
{
my ($session, $table, $router,  $snmp_variables ) = @_;
foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list})))
        {
        foreach my $attribute ( keys %{$snmp_variables} )
                {
                next if $attribute=~/^PRIVATE/;
                if ( $oid =~ /^${$snmp_variables}{$attribute}.(\d+).(\d+).(\d+).(\d+).(\d+).(\d+)/)
                        {
                        my $index="$3.$4.$5.$6";
                        my $int_index=$1;
			${$table}{$router}{$int_index}{'address'}{$index}{$attribute}=$session->var_bind_list->{$oid};
			}
                }
        delete ( $session->var_bind_list->{$oid} );
        }

return 1;
}

sub validate_four_net
{
my ($session, $table, $router,  $snmp_variables ) = @_;
my (%temp);

foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list})))
	{
	foreach my $attribute ( keys %{$snmp_variables} )
		{
		if ( $attribute=~/ipAdEntIfIndex/i )
			{
			if ( $oid =~ /^${$snmp_variables}{$attribute}.(\d+).(\d+).(\d+).(\d+)/)
				{
				my $index="$1.$2.$3.$4";
				$temp{$index}=$session->var_bind_list->{$oid};
				}
			}
		}
	}

foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list})))
        {
        foreach my $attribute ( keys %{$snmp_variables} )
                {
                next if $attribute=~/^PRIVATE/;
                if ( $oid =~ /^${$snmp_variables}{$attribute}.(\d+).(\d+).(\d+).(\d+)/)
                        {
			my $index="$1.$2.$3.$4";
			my $int_index=$temp{$index};		
                        ${$table}{$router}{$int_index}{'address'}{$index}{$attribute}=$session->var_bind_list->{$oid};
                        }
                }
        delete ( $session->var_bind_list->{$oid} );
        }
return 1;
}

sub get_cpe_information
{
my ($session, $ip, $table, $snmp_variables ) = @_;
foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) 
	{
	foreach my $attribute ( keys %{$snmp_variables} )
		{
		next if $attribute=~/^PRIVATE/;
		if ( $oid =~ /^${$snmp_variables}{$attribute}/)
			{
			${$table}{$ip}{$attribute}=$session->var_bind_list->{$oid};
			}
		}
	delete ( $session->var_bind_list->{$oid} );
	}
return 1;
}

sub _IpQuadToInt {
my $self = shift;
my($Quad) = @_; my($Ip1, $Ip2, $Ip3, $Ip4) = split(/\./, $Quad);
my($IpInt) = (($Ip1 << 24) | ($Ip2 << 16) | ($Ip3 << 8) | $Ip4);
return($IpInt);
}

sub _IpIntToQuad { my $self= shift; my($Int) = @_;
my($Ip1) = $Int & 0xFF; $Int >>= 8;
my($Ip2) = $Int & 0xFF; $Int >>= 8;
my($Ip3) = $Int & 0xFF; $Int >>= 8;
my($Ip4) = $Int & 0xFF; return("$Ip4.$Ip3.$Ip2.$Ip1");
}

=head1 BUGS

It is has been discovered using Non blocking functions on Cisco routers does
not always return the same consistent information compared to Blocking. It is
the opinion of the author to only use Blocking unless you know what you are doing,
and all functions will have Blocking mirrors in the first public release.

Module now semi supports blocking and non blocking mode.
It has been discovered that non-blocking is significantly longer to
execute. Not entirely sure why, however to speed things up
some functions now have _Blocking mirrors so they can be called
instead.

Added support to retrieve the STM information very simple implementation
to poll the STM mib provided on Cisco equipment.
Added support to ONLY poll STM information when within all STM windows.

Added Network Link Map Generator
Added CPE snmp read key cycler ( not finished ).

Please report any bugs or feature requests to
C<bug-router-statistics at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Router-Statistics>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Router::Statistics

=head1 ACKNOWLEDGEMENTS

Cisco I suppose for making their products such a nightmare to manage using
SNMP.

Joshua Keroes for pointing out some of the make test issues ( thanks!! )

Motorola for some pointers with their CMTS ( still waiting on some info )

=head1 COPYRIGHT & LICENSE

Copyright 2007 Andrew S. Kennedy, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Router::Statistics

