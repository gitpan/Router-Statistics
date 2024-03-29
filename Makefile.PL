use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Router::Statistics',
    AUTHOR              => 'Andrew S. Kennedy <shamrock@cpan.org>',
    VERSION_FROM        => 'lib/Router/Statistics.pm',
    ABSTRACT_FROM       => 'lib/Router/Statistics.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'Net::SNMP'  => '1',
	'Net::Telnet' => '3.03',
	'MIME::Base64' => '3.07'
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Router-Statistics-*' },
);
