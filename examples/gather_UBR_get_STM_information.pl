#!/usr/bin/perl

use Router::Statistics;
use strict;

# Written by Andrew S. Kennedy 2nd December 2006

my (%inventory, %routers, %final_result_set, %telnet_inventory );
my $result;
my $test= new Router::Statistics;

my @router_list = qw [ 10.1.1.1:public 10.1.1.2:public ];

foreach my $router ( @router_list )
	{
	my ( $router_ip, $router_key ) = (split(/:/,$router))[0,1];
	$result = $test->Router_Add( $router_ip , $router_key );
	$result = $test->Router_Ready_Blocking ( $router_ip );
	}

$result = $test->Router_Test_Connection_Blocking(\%routers);
if ( scalar( keys %routers )==0 )
{ print "No access to Any of the Routers specified.\n";exit(0); }

my %inventory_telnet;

$result = $test->UBR_get_stm_Blocking( 
		\%routers, 
		\%inventory, 
		\%inventory_telnet, 
		"loginname", "loginpassword" );

#Now we have both sets of data, lets merge them

foreach my $entry ( keys %inventory )
	{
	foreach my $outer ( keys %{$inventory{$entry}} )
		{
		my $mac=$inventory{$entry}{$outer}{'ccqmEnfRuleViolateMacAddr'};
		my $detect = $inventory{$entry}{$outer}{'ccqmEnfRuleViolateLastDetectTime'};
		my $unique_instance = $mac."#".$detect;
		$final_result_set{$entry}{$unique_instance}{'ccqmEnfRuleViolateMacAddr'}=
					$inventory{$entry}{$outer}{'ccqmEnfRuleViolateMacAddr'};
		$final_result_set{$entry}{$unique_instance}{'ccqmEnfRuleViolateLastDetectTime'}=
					$inventory{$entry}{$outer}{'ccqmEnfRuleViolateLastDetectTime'};
		$final_result_set{$entry}{$unique_instance}{'ccqmEnfRuleViolatePenaltyExpTime'}=
					$inventory{$entry}{$outer}{'ccqmEnfRuleViolatePenaltyExpTime'};
		$final_result_set{$entry}{$unique_instance}{'ccqmEnfRuleViolateRuleName'}=
					$inventory{$entry}{$outer}{'ccqmEnfRuleViolateRuleName'};
		}
	}

foreach my $entry ( keys %inventory_telnet )
	{
	foreach my $outer ( keys %{$inventory_telnet{$entry}} )
		{
		my $mac=$inventory_telnet{$entry}{$outer}{'ccqmEnfRuleViolateMacAddr'};
		my $detect = $inventory_telnet{$entry}{$outer}{'ccqmEnfRuleViolateLastDetectTime'};
		my $unique_instance = $mac."#".$detect;
		$final_result_set{$entry}{$unique_instance}{'ccqmEnfRuleViolateMacAddr'}=
					$inventory_telnet{$entry}{$outer}{'ccqmEnfRuleViolateMacAddr'};
		$final_result_set{$entry}{$unique_instance}{'ccqmEnfRuleViolateLastDetectTime'}=
					$inventory_telnet{$entry}{$outer}{'ccqmEnfRuleViolateLastDetectTime'};
		$final_result_set{$entry}{$unique_instance}{'ccqmEnfRuleViolatePenaltyExpTime'}=
					$inventory_telnet{$entry}{$outer}{'ccqmEnfRuleViolatePenaltyExpTime'};
		$final_result_set{$entry}{$unique_instance}{'ccqmEnfRuleViolateRuleName'}=
					$inventory_telnet{$entry}{$outer}{'ccqmEnfRuleViolateRuleName'};
		}
	}

# Now we have them merged ... we print them out ... or something

foreach my $router ( keys %final_result_set )
	{
	foreach my $instance ( keys %{$final_result_set{$router}} )
		{
		print "$router,$instance,$final_result_set{$router}{$instance}{'ccqmEnfRuleViolateMacAddr'},";
		print "$final_result_set{$router}{$instance}{'ccqmEnfRuleViolateRuleName'},";
		print "$final_result_set{$router}{$instance}{'ccqmEnfRuleViolateLastDetectTime'},";
		print "$final_result_set{$router}{$instance}{'ccqmEnfRuleViolatePenaltyExpTime'}\n";
		}
	}

