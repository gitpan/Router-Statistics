#!perl -T

use Test::More tests => 2;

BEGIN {
	use_ok( 'Router::Statistics' );
	use_ok( 'Router::Statistics::OID' );
}

diag( "Testing Router::Statistics $Router::Statistics::VERSION, Perl $], $^X" );
