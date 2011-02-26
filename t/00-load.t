#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Google::CSE' ) || print "Bail out!
";
}

diag( "Testing Google::CSE $Google::CSE::VERSION, Perl $], $^X" );
