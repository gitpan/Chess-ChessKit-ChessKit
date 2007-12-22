#!perl -T

use Test::More tests => 4;

BEGIN {
	use_ok( 'Chess::ChessKit::ChessKit' );
	use_ok( 'Chess::ChessKit::Move' );
	use_ok( 'Chess::ChessKit::Board' );
	use_ok( 'Chess::ChessKit::Trad' );
}

diag( "Testing Chess::ChessKit::ChessKit $Chess::ChessKit::ChessKit::VERSION, Perl $], $^X" );
