package Router::Statistics::OID;

use strict vars;

=head1 NAME

Router::Statistics::OID - OID Module for Router::Statistics

=head1 VERSION

Version 1.45

our $VERSION = '1.45';

=head1 SYNOPSIS

This module provides the OID to name mappings required by the Router::Statistics
module.

=head1 FUNCTIONS

These functions are used internally to Router::Statistics however may become more
'friendly' in the future.

telnet_commands
CPE_populate_oid
CPE_DOCSIS_populate_oid ( currently CPE_populate_oid wraps this for backward compatibility )
Router_Link_Map_oid
Router_inventory_oid
Router_interface_oid
Host_populate_oid
STM_populate_oid
DOCSIS_populate_oid

# Andrew S. Kennedy ( shamrock@cpan.org )

=cut

sub new {

        my $self = {};
	bless $self;

	my ( $class , $attr ) =@_;

	while (my($field, $val) = splice(@{$attr}, 0, 2)) 
		{ $self->{_GLOBAL}{$field}=$val; }

	$self->{_GLOBAL}{'STATUS'}="OK";

        return $self;
}

sub telnet_commands
{
my %telnet_command_set =
		(
		'termline'			=>	'dGVybSBsZW4gMA==',
		'stm_command'			=>	'c2ggY2FibGUgc3Vic2NyaWJlci11c2FnZSB8IGluY2x1ZGUgQWN0',
		'page_off'			=>	'cGFnZSBvZmY=',
		'show_running_config'		=>	'c2hvdyBydW5uaW5nLWNvbmZpZw=='
		);
return \%telnet_command_set;
}

sub CPE_populate_oid
{
return CPE_DOCSIS_populate_oid();
}

sub CPE_DOCSIS_populate_oid
{
my %snmp_usable_oid =
			(
		'sysDescr'			=>	'1.3.6.1.2.1.1.1.0',
		'sysUpTime'                     =>      '1.3.6.1.2.1.1.3.0',
		'sysORDescr'			=>	'1.3.6.1.2.1.1.9.0',
		'docsDevSwCurrentVers'		=>	'1.3.6.1.2.1.69.1.3.5.0',
		'ifPhysAddress'			=>	'1.3.6.1.2.1.2.2.1.6.1',
		'DownStreamFrequency'		=>	'1.3.6.1.2.1.10.127.1.1.1.1.2.3',
		'DownStreamWidth'		=>	'1.3.6.1.2.1.10.127.1.1.1.1.3.3',
		'UpStreamFrequency'		=>	'1.3.6.1.2.1.10.127.1.1.2.1.2.4',
		'UpStreamWidth'			=>	'1.3.6.1.2.1.10.127.1.1.2.1.3.4',
		'SoftwareVersion'		=>	'1.3.6.1.2.1.69.1.3.5.0',
		'DOCSISFileName'		=>	'1.3.6.1.2.1.69.1.4.5.0',
		'DOCSISUpstreamWidth'   	=>      '1.3.6.1.2.1.10.127.1.1.3.1.3.1',
		'DOCSISDownstreamWidth' 	=>      '1.3.6.1.2.1.10.127.1.1.3.1.5.1',
		'docsIfSigQIncludesContention'	=>	'1.3.6.1.2.1.10.127.1.1.4.1.1.3',
		'docsIfSigQUnerroreds'		=>	'1.3.6.1.2.1.10.127.1.1.4.1.2.3',
		'docsIfSigQCorrecteds' 		=>	'1.3.6.1.2.1.10.127.1.1.4.1.3.3',
		'docsIfSigQUncorrectables'	=>	'1.3.6.1.2.1.10.127.1.1.4.1.4.3',
		'docsIfSigQSignalNoise'		=>	'1.3.6.1.2.1.10.127.1.1.4.1.5.3',
		'docsIfSigQMicroreflections'	=>	'1.3.6.1.2.1.10.127.1.1.4.1.6.3',
		'docsIfSigQEqualizationData'	=>	'1.3.6.1.2.1.10.127.1.1.4.1.7.3',
		'docsIfSigQExtUnerroreds'	=>	'1.3.6.1.2.1.10.127.1.1.4.1.8.3',
		'docsIfSigQExtCorrecteds'	=>	'1.3.6.1.2.1.10.127.1.1.4.1.9.3',
		'docsIfSigQExtUncorrectables'	=>	'1.3.6.1.2.1.10.127.1.1.4.1.10.3',
		'docsIfCmCapabilities'		=>	'1.3.6.1.2.1.10.127.1.2.1.1.2.0',
		'docsIfCmCapabilities1'		=>	'1.3.6.1.2.1.10.127.1.2.1.1.2.1',
		'docsIfCmCapabilities2'		=>	'1.3.6.1.2.1.10.127.1.2.1.1.2.2',
		'docsDevSwFilename'		=>	'1.3.6.1.2.1.69.1.3.2.0',
		'docsDevSwServer'		=>	'1.3.6.1.2.1.69.1.3.1.0',
		'docsDevSwAdminStatus'		=>	'1.3.6.1.2.1.69.1.3.3.0',
		'docsDevResetNow'		=>	'1.3.6.1.2.1.69.1.1.3.0'
			);
return \%snmp_usable_oid;
}

sub Router_Link_Map_oid
{
my %snmp_usable_oid =
		(
		'PRIVATE_ipEnt'			=>	'1.3.6.1.2.1.4.20.1',
		'ipAdEntAddr'			=>	'1.3.6.1.2.1.4.20.1.1',
		'ipAdEntIfIndex'		=>	'1.3.6.1.2.1.4.20.1.2',
		'ipAdEntNetMask'		=>	'1.3.6.1.2.1.4.20.1.3',
		'PRIVATE_atEnt'			=>	'1.3.6.1.2.1.3.1.1',
		'atIfIndex'			=>	'1.3.6.1.2.1.3.1.1.1',
		'atPhysAddress'			=>	'1.3.6.1.2.1.3.1.1.2',
		'atNetAddress'			=>	'1.3.6.1.2.1.3.1.1.3',
		'portCrossIndex'		=>	'1.3.6.1.4.1.9.5.1.4.1.1.3',
		'dot1dBasePortIfIndex'		=>	'1.3.6.1.2.1.17.1.4.1.2',
		'dot1dTpFdbPort'		=>	'1.3.6.1.2.1.17.4.3.1.2'
		);
return \%snmp_usable_oid;
}
		

sub Router_inventory_oid
{
my %snmp_usable_oid =
		(
		'PRIVATE_inventory' 		=>	'1.3.6.1.2.1.47.1.1.1.1',
		'entPhysicalDescr'		=>	'1.3.6.1.2.1.47.1.1.1.1.2',
		'entPhysicalParentRelPos'	=>	'1.3.6.1.2.1.47.1.1.1.1.6',
		'entPhysicalName'		=>	'1.3.6.1.2.1.47.1.1.1.1.7',
		'entPhysicalSerialNum'		=>	'1.3.6.1.2.1.47.1.1.1.1.11',
		'entPhysicalModelName'		=>	'1.3.6.1.2.1.47.1.1.1.1.13',
		'entPhysicalAssetID'		=>	'1.3.6.1.2.1.47.1.1.1.1.15',
		'entPhysicalMfgDate'		=>	'1.3.6.1.2.1.47.1.1.1.1.17'
		);
return \%snmp_usable_oid;
}

sub Router_interface_oid_hc
{
my %snmp_usable_oid =
		(
		'PRIVATE_interface_base'	=> '1.3.6.1.2.1.31.1.1.1',
		'ifName'			=> '1.3.6.1.2.1.31.1.1.1.1',
		'ifInMulticastPkts'		=> '1.3.6.1.2.1.31.1.1.1.2',
		'ifInBroadcastPkts'		=> '1.3.6.1.2.1.31.1.1.1.3',
		'ifOutMulticastPkts'		=> '1.3.6.1.2.1.31.1.1.1.4',
		'ifOutBroadcastPkts'		=> '1.3.6.1.2.1.31.1.1.1.5',
		'ifHCInOctets'			=> '1.3.6.1.2.1.31.1.1.1.6',
		'ifHCInUcastPkts'		=> '1.3.6.1.2.1.31.1.1.1.7',
		'ifHCInMulticastPkts'		=> '1.3.6.1.2.1.31.1.1.1.8',
		'ifHCInBroadcastPkts'		=> '1.3.6.1.2.1.31.1.1.1.9',
		'ifHCOutOctets'			=> '1.3.6.1.2.1.31.1.1.1.10',
		'ifHCOutUcastPkts'		=> '1.3.6.1.2.1.31.1.1.1.11',
		'ifHCOutMulticastPkts'		=> '1.3.6.1.2.1.31.1.1.1.12',
		'ifHCOutBroadcastPkts'		=> '1.3.6.1.2.1.31.1.1.1.13',
		'ifLinkUpDownTrapEnable'	=> '1.3.6.1.2.1.31.1.1.1.14',
		'ifHighSpeed'			=> '1.3.6.1.2.1.31.1.1.1.15',
		'ifPromiscuousMode'		=> '1.3.6.1.2.1.31.1.1.1.16',
		'ifConnectorPresent'		=> '1.3.6.1.2.1.31.1.1.1.17',
		'ifAlias'			=> '1.3.6.1.2.1.31.1.1.1.18',
		'ifCounterDiscontinuityTime'	=> '1.3.6.1.2.1.31.1.1.1.19'
		);
return \%snmp_usable_oid;
}


sub Router_interface_oid
{
my %snmp_usable_oid =
	(
		'PRIVATE_interface_base'	=>	'1.3.6.1.2.1.2.2.1',
		'ifDescr'			=>	'1.3.6.1.2.1.2.2.1.2',
		'ifType'			=>	'1.3.6.1.2.1.2.2.1.3',
		'ifMtu'				=>	'1.3.6.1.2.1.2.2.1.4',
		'ifSpeed'			=>	'1.3.6.1.2.1.2.2.1.5',
		'ifPhysAddress'			=>	'1.3.6.1.2.1.2.2.1.6',
		'ifAdminStatus'  		=>      '1.3.6.1.2.1.2.2.1.7',
		'ifOperStatus'			=>	'1.3.6.1.2.1.2.2.1.8',
		'ifLastChange'			=>	'1.3.6.1.2.1.2.2.1.9',
		'ifInOctets'			=>	'1.3.6.1.2.1.2.2.1.10',
		'ifInUcastPkts'			=>	'1.3.6.1.2.1.2.2.1.11',
		'ifInNUcastPkts'		=>	'1.3.6.1.2.1.2.2.1.12',
		'ifInDiscards'			=>	'1.3.6.1.2.1.2.2.1.13',
		'ifInErrors'			=>	'1.3.6.1.2.1.2.2.1.14',
		'ifInUnknownProtos'		=>	'1.3.6.1.2.1.2.2.1.15',
		'ifOutOctets'			=>	'1.3.6.1.2.1.2.2.1.16',
		'ifOutUcastPkts'		=>	'1.3.6.1.2.1.2.2.1.17',
		'ifOutNUcastPkts'		=>	'1.3.6.1.2.1.2.2.1.18',
		'ifOutDiscards'			=>	'1.3.6.1.2.1.2.2.1.19',
		'ifOutErrors'			=>	'1.3.6.1.2.1.2.2.1.20',
		'ifAlias'			=>	'1.3.6.1.2.1.31.1.1.1.18'
	);
return \%snmp_usable_oid
}

sub Host_populate_oid
{
my %snmp_usable_oid =
	(
		'sysDescr'			=>      '1.3.6.1.2.1.1.1.0',
        	'sysUpTime'			=>      '1.3.6.1.2.1.1.3.0',
		'sysName'			=>	'1.3.6.1.2.1.1.5.0',
        	'hostName'			=>      '1.3.6.1.4.1.9.2.1.3.0',
        	'whyReload'			=>      '1.3.6.1.4.1.9.2.1.2.0',
        	'entPhysicalDescr.1'		=>      '1.3.6.1.2.1.47.1.1.1.1.2.1',
        	'entPhysicalDescr.2'		=>      '1.3.6.1.2.1.47.1.1.1.1.2.2'
	);
return \%snmp_usable_oid;
}

sub ntp_populate_oid
{
my %snmp_ntp_oid =
	(
	'cntpSysClock'			=>	'1.3.6.1.4.1.9.9.168.1.1.10.0'
	);
return \%snmp_ntp_oid;
}

sub STM_populate_oid
{
my %snmp_stm_oid =
        (
	'PRIVATE_stm_rule_base'		=>	'1.3.6.1.4.1.9.9.341.1.1.1',
	'PRIVATE_cqmCmtsEnfRuleName'	=>	'1.3.6.1.4.1.9.9.341.1.1.1.1',
	'ccqmCmtsEnfRuleRegQoS'		=>	'1.3.6.1.4.1.9.9.341.1.1.1.1.2',
	'ccqmCmtsEnfRuleEnfQos'		=>	'1.3.6.1.4.1.9.9.341.1.1.1.1.3',
	'ccqmCmtsEnfRuleMonDuration'	=>	'1.3.6.1.4.1.9.9.341.1.1.1.1.4',
	'ccqmCmtsEnfRuleSampleRate'	=>	'1.3.6.1.4.1.9.9.341.1.1.1.1.5',
	'ccqmCmtsEnfRulePenaltyPeriod'	=>	'1.3.6.1.4.1.9.9.341.1.1.1.1.6',
	'ccqmCmtsEnfRuleByteCount'	=>	'1.3.6.1.4.1.9.9.341.1.1.1.1.7',
	'ccqmCmtsEnfRuleDirection'	=>	'1.3.6.1.4.1.9.9.341.1.1.1.1.8',
	'ccqmCmtsEnfRuleAutoEnforce'	=>	'1.3.6.1.4.1.9.9.341.1.1.1.1.9',
	'ccqmCmtsEnfRuleRowStatus'	=>	'1.3.6.1.4.1.9.9.341.1.1.1.1.10',
	'ccqmCmtsEnfRuleStartTime'	=>	'1.3.6.1.4.1.9.9.341.1.1.1.1.16',
	'ccqmCmtsEnfRuleDuration'	=>	'1.3.6.1.4.1.9.9.341.1.1.1.1.17',
	'ccqmCmtsEnfRuleAverage'	=>	'1.3.6.1.4.1.9.9.341.1.1.1.1.18',
        'PRIVATE_stm_base'              =>      '1.3.6.1.4.1.9.9.341.1.2.2',
        'ccqmEnfRuleViolateID'          =>      '1.3.6.1.4.1.9.9.341.1.2.2.1.1',
        'ccqmEnfRuleViolateMacAddr'     =>      '1.3.6.1.4.1.9.9.341.1.2.2.1.2',
        'ccqmEnfRuleViolateRuleName'    =>      '1.3.6.1.4.1.9.9.341.1.2.2.1.3',
        'ccqmEnfRuleViolateByteCount'   =>      '1.3.6.1.4.1.9.9.341.1.2.2.1.4',
        'ccqmEnfRuleViolateLastDetectTime'      =>      '1.3.6.1.4.1.9.9.341.1.2.2.1.5',
        'ccqmEnfRuleViolatePenaltyExpTime'      =>      '1.3.6.1.4.1.9.9.341.1.2.2.1.6'
        );
return \%snmp_stm_oid;
}

sub DOCSIS_Modulation
{
my %profile_info = (
        'PRIVATE_docsIfCmtsMod_base'            =>      '.1.3.6.1.2.1.10.127.1.3.5.1',
        'docsIfCmtsModIndex'                    =>      '.1.3.6.1.2.1.10.127.1.3.5.1.1',
        'docsIfCmtsModIntervalUsageCode'        =>      '.1.3.6.1.2.1.10.127.1.3.5.1.2',
        'docsIfCmtsModControl'                  =>      '.1.3.6.1.2.1.10.127.1.3.5.1.3',
        'docsIfCmtsModType'                     =>      '.1.3.6.1.2.1.10.127.1.3.5.1.4',
        'docsIfCmtsModPreambleLen'              =>      '.1.3.6.1.2.1.10.127.1.3.5.1.5',
        'docsIfCmtsModDifferentialEncoding'     =>      '.1.3.6.1.2.1.10.127.1.3.5.1.6',
        'docsIfCmtsModFECErrorCorrection'       =>      '.1.3.6.1.2.1.10.127.1.3.5.1.7',
        'docsIfCmtsModFECCodewordLength'        =>      '.1.3.6.1.2.1.10.127.1.3.5.1.8',
        'docsIfCmtsModScramblerSeed'            =>      '.1.3.6.1.2.1.10.127.1.3.5.1.9',
        'docsIfCmtsModMaxBurstSize'             =>      '.1.3.6.1.2.1.10.127.1.3.5.1.10',
        'docsIfCmtsModGuardTimeSize'            =>      '.1.3.6.1.2.1.10.127.1.3.5.1.11',
        'docsIfCmtsModLastCodewordShortened'    =>      '.1.3.6.1.2.1.10.127.1.3.5.1.12',
        'docsIfCmtsModScrambler'                =>      '.1.3.6.1.2.1.10.127.1.3.5.1.13',
        'docsIfCmtsModByteInterleaverDepth'     =>      '.1.3.6.1.2.1.10.127.1.3.5.1.14',
        'docsIfCmtsModByteInterleaverBlockSize' =>      '.1.3.6.1.2.1.10.127.1.3.5.1.15',
        'docsIfCmtsModPreambleType'             =>      '.1.3.6.1.2.1.10.127.1.3.5.1.16',
        'docsIfCmtsModTcmErrorCorrectionOn'     =>      '.1.3.6.1.2.1.10.127.1.3.5.1.17',
        'docsIfCmtsModScdmaInterleaverStepSize' =>      '.1.3.6.1.2.1.10.127.1.3.5.1.18',
        'docsIfCmtsModScdmaSpreaderEnable'      =>      '.1.3.6.1.2.1.10.127.1.3.5.1.19',
        'docsIfCmtsModScdmaSubframeCodes'       =>      '.1.3.6.1.2.1.10.127.1.3.5.1.20',
        'docsIfCmtsModChannelType'              =>      '.1.3.6.1.2.1.10.127.1.3.5.1.21' );
return \%profile_info;
}

sub DOCSIS_packet_cable
{
# this is temp name for DOCSIS3/Wideband/Service flow environments
my %snmp_usable_oid=
	(
	'docsIfCmtsCmStatusMacAddress'		=>	'1.3.6.1.2.1.10.127.1.3.3.1.2',
	'docsIfCmtsMacToCmEntry'		=>	'1.3.6.1.2.1.10.127.1.3.7.1.2'
	);
return \%snmp_usable_oid;
}
	

sub DOCSIS_populate_oid
{

my %snmp_usable_oid =
	(
	'PRIVATE_cable_signal_base'		=>	'1.3.6.1.2.1.10.127.1.1.4.1',
	'docsIfSigQIncludesContention'		=>	'1.3.6.1.2.1.10.127.1.1.4.1.1',
	'docsIfSigQUnerroreds'			=>	'1.3.6.1.2.1.10.127.1.1.4.1.2',
	'docsIfSigQCorrecteds'			=>	'1.3.6.1.2.1.10.127.1.1.4.1.3',
	'docsIfSigQUncorrectables'		=>	'1.3.6.1.2.1.10.127.1.1.4.1.4',
	'docsIfSigQSignalNoise'			=>	'1.3.6.1.2.1.10.127.1.1.4.1.5',
	'docsIfSigQMicroreflections'		=>	'1.3.6.1.2.1.10.127.1.1.4.1.6',
	'docsIfSigQEqualizationData'		=>	'1.3.6.1.2.1.10.127.1.1.4.1.7',
	'PRIVATE_cable_channel_information'	=> 	'1.3.6.1.4.1.9.9.116.1.4.1.1',
	'cdxIfUpChannelModulationProfile'	=> 	'1.3.6.1.4.1.9.9.116.1.4.1.1.2',
	'cdxIfUpChannelCmTotal'			=>	'1.3.6.1.4.1.9.9.116.1.4.1.1.3',
	'cdxIfUpChannelCmActive'		=>	'1.3.6.1.4.1.9.9.116.1.4.1.1.4',
	'cdxIfUpChannelCmRegistered'		=>	'1.3.6.1.4.1.9.9.116.1.4.1.1.5',
	'cdxIfUpChannelInputPowerLevel'		=>	'1.3.6.1.4.1.9.9.116.1.4.1.1.6',
	'cdxIfUpChannelAvgUtil'			=>	'1.3.6.1.4.1.9.9.116.1.4.1.1.7',
	'cdxIfUpChannelAvgContSlots'		=>	'1.3.6.1.4.1.9.9.116.1.4.1.1.8',
	'cdxIfUpChannelRangeSlots'		=>	'1.3.6.1.4.1.9.9.116.1.4.1.1.9',
	'cdxIfUpChannelNumActiveUGS'		=>	'1.3.6.1.4.1.9.9.116.1.4.1.1.10',
	'PRIVATE_cable_channel_parameters'	=>	'1.3.6.1.2.1.10.127.1.1.2.1',
	'docsIfUpChannelFrequency'		=>	'1.3.6.1.2.1.10.127.1.1.2.1.2',
	'docsIfUpChannelWidth'			=>	'1.3.6.1.2.1.10.127.1.1.2.1.3',
	'docsIfUpChannelModulationProfile'	=>	'1.3.6.1.2.1.10.127.1.1.2.1.4',
	'docsIfUpChannelSlotSize'		=>	'1.3.6.1.2.1.10.127.1.1.2.1.5',
	'docsIfUpChannelTxTimingOffset'		=>	'1.3.6.1.2.1.10.127.1.1.2.1.6',
	'docsIfUpChannelRangingBackoffStart'	=>	'1.3.6.1.2.1.10.127.1.1.2.1.7',
	'docsIfUpChannelRangingBackoffEnd'	=>	'1.3.6.1.2.1.10.127.1.1.2.1.8',
	'docsIfUpChannelTxBackoffStart'		=>	'1.3.6.1.2.1.10.127.1.1.2.1.9',
	'docsIfUpChannelTxBackoffEnd'		=>	'1.3.6.1.2.1.10.127.1.1.2.1.10',
	'docsIfCmtsUpChannelCounterEntry'	=>	'1.3.6.1.2.1.10.127.1.3.11.1',
	'docsIfCmtsUpChnlCtrTotalMslots'	=>	'1.3.6.1.2.1.10.127.1.3.11.1.2',
	'docsIfCmtsUpChnlCtrUcastGrantedMslots'	=>	'1.3.6.1.2.1.10.127.1.3.11.1.3',
	'docsIfCmtsUpChnlCtrTotalCntnMslots'	=>	'1.3.6.1.2.1.10.127.1.3.11.1.4',
	'docsIfCmtsUpChnlCtrUsedCntnMslots'	=>	'1.3.6.1.2.1.10.127.1.3.11.1.5',
	'PRIVATE_downstream_interface'		=>	'1.3.6.1.2.1.10.127.1.1.1.1',
	'docsIfDownChannelFrequency'		=>	'1.3.6.1.2.1.10.127.1.1.1.1.2',
	'docsIfDownChannelWidth'		=>	'1.3.6.1.2.1.10.127.1.1.1.1.3',
	'docsIfDownChannelModulation'		=>	'1.3.6.1.2.1.10.127.1.1.1.1.4',
	'docsIfDownChannelInterleave'		=>	'1.3.6.1.2.1.10.127.1.1.1.1.5',
	'docsIfDownChannelPower'   		=>	'1.3.6.1.2.1.10.127.1.1.1.1.6',
	'docsIfDownChannelAnnex' 		=>	'1.3.6.1.2.1.10.127.1.1.1.1.7',
	'docsIfCmtsCmStatusMacAddress'		=>      '1.3.6.1.2.1.10.127.1.3.3.1.2',
	'docsIfCmtsCmStatusIpAddress'		=>      '1.3.6.1.2.1.10.127.1.3.3.1.3', 
	'docsIfCmtsCmStatusUpChannelIfIndex'	=>	'1.3.6.1.2.1.10.127.1.3.3.1.5',
	'docsIfCmtsCmStatusValue'		=>  	'1.3.6.1.2.1.10.127.1.3.3.1.9',
	'docsIfCmtsServiceCmStatusIndex'	=>	'1.3.6.1.2.1.10.127.1.3.4.1.2',
	'docsIfCmtsServiceQosProfile'		=> 	'1.3.6.1.2.1.10.127.1.3.4.1.4',
	'docsIfCmtsServiceInOctets'		=>	'1.3.6.1.2.1.10.127.1.3.4.1.6',
	'docsIfCmtsServiceInPackets'		=>	'1.3.6.1.2.1.10.127.1.3.4.1.7',
	'cdxIfCmtsServiceOutOctets'		=>	'1.3.6.1.4.1.9.9.116.1.1.3.1.1',
	'cdxIfCmtsServiceOutPackets'		=>	'1.3.6.1.4.1.9.9.116.1.1.3.1.2',
	'cdxCmCpeIpAddress'			=>	'1.3.6.1.4.1.9.9.116.1.3.1.1.3',
	'cdxCmCpeCmStatusIndex'			=>	'1.3.6.1.4.1.9.9.116.1.3.1.1.6',
	'ciscoMemoryPoolUsed'			=>	'1.3.6.1.4.1.9.9.48.1.1.1.5',
	'ciscoMemoryPoolFree'			=>	'1.3.6.1.4.1.9.9.48.1.1.1.6',
	'entPhysicalDescr' 			=>	'1.3.6.1.2.1.47.1.1.1.1.2',
	'entPhysicalParentRelPos'		=>	'1.3.6.1.2.1.47.1.1.1.1.6',
	'entAliasMappingIdentifier'		=>	'1.3.6.1.2.1.47.1.3.2.1.2',
	'entPhysicalName'			=>	'1.3.6.1.2.1.47.1.1.1.1.7',
	'cdxCmCpeResetNow'			=>	'1.3.6.1.4.1.9.9.116.1.3.1.1.8',
	'PRIVATE_docs_profile_main'		=>	'1.3.6.1.2.1.10.127.1.1.3.1',
	'docsIfQosProfPriority'			=>	'1.3.6.1.2.1.10.127.1.1.3.1.2',
	'docsIfQosProfMaxUpBandwidth'		=>	'1.3.6.1.2.1.10.127.1.1.3.1.3',
	'docsIfQosProfMaxDownBandwidth'		=>	'1.3.6.1.2.1.10.127.1.1.3.1.5',
	'cdxCmtsCmCurrQoSPro'			=>	'1.3.6.1.4.1.9.9.116.1.3.6.1.3',
	'PRIVATE_docsIfCmtsModulationEntry'	=>	'1.3.6.1.2.1.10.127.1.3.5.1',
	'docsIfCmtsModIndex'			=>	'1.3.6.1.2.1.10.127.1.3.5.1.1',
	'docsIfCmtsModIntervalUsageCode'	=>	'1.3.6.1.2.1.10.127.1.3.5.1.2',
	'docsIfCmtsModControl'			=>	'1.3.6.1.2.1.10.127.1.3.5.1.3',
	'docsIfCmtsModType'			=>	'1.3.6.1.2.1.10.127.1.3.5.1.4',
	'docsIfCmtsModPreambleLen'		=>	'1.3.6.1.2.1.10.127.1.3.5.1.5',
	'docsIfCmtsModDifferentialEncoding'	=>	'1.3.6.1.2.1.10.127.1.3.5.1.6',
	'docsIfCmtsModFECErrorCorrection'	=>	'1.3.6.1.2.1.10.127.1.3.5.1.7',
	'docsIfCmtsModFECCodewordLength'	=>	'1.3.6.1.2.1.10.127.1.3.5.1.8',
	'docsIfCmtsModScramblerSeed'		=>	'1.3.6.1.2.1.10.127.1.3.5.1.9',
	'docsIfCmtsModMaxBurstSize'		=>	'1.3.6.1.2.1.10.127.1.3.5.1.10',
	'docsIfCmtsModGuardTimeSize'		=>	'1.3.6.1.2.1.10.127.1.3.5.1.11',
	'docsIfCmtsModLastCodewordShortened'	=>	'1.3.6.1.2.1.10.127.1.3.5.1.12',
	'docsIfCmtsModScrambler'		=>	'1.3.6.1.2.1.10.127.1.3.5.1.13',
	'docsIfCmtsModByteInterleaverDepth'	=>	'1.3.6.1.2.1.10.127.1.3.5.1.14',
	'docsIfCmtsModByteInterleaverBlockSize'	=>	'1.3.6.1.2.1.10.127.1.3.5.1.15',
	'docsIfCmtsModPreambleType'		=>	'1.3.6.1.2.1.10.127.1.3.5.1.16',
	'docsIfCmtsModTcmErrorCorrectionOn'	=>	'1.3.6.1.2.1.10.127.1.3.5.1.17',
	'docsIfCmtsModScdmaInterleaverStepSize'	=>	'1.3.6.1.2.1.10.127.1.3.5.1.18',
	'docsIfCmtsModScdmaSpreaderEnable'	=>	'1.3.6.1.2.1.10.127.1.3.5.1.19',
	'docsIfCmtsModScdmaSubframeCodes'	=>	'1.3.6.1.2.1.10.127.1.3.5.1.20',
	'docsIfCmtsModChannelType'		=>	'1.3.6.1.2.1.10.127.1.3.5.1.21'
	);

return \%snmp_usable_oid;
}

=head1 AUTHOR

Andrew S. Kennedy, C<< <shamrock at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-router-statistics at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Router-Statistics>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Router::Statistics

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Router-Statistics>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Router-Statistics>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Router-Statistics>

=item * Search CPAN

L<http://search.cpan.org/dist/Router-Statistics>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Andrew S. Kennedy, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Router::Statistics::OID
