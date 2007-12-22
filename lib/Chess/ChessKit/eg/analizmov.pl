#!/usr/bin/perl -w
####-----------------------------------
### File	: analizmov.pl
### Author	: C.Minc
### Purpose	: Count valid moves and checks
### Version	: 1.2 2007/12/22
### copyright GNU license
####-----------------------------------



use strict;
use warnings;

use Chess::PGN::Parse 0.18 ;
use Chess::ChessKit::Board  ;


our $VERSION = '1.2';

# global local vars
my $ref ;
my $currMove = 1;
my $piece ;
my $from ;
my $take ;
my $dest ;
my $check ;
my @start ;
my $status={} ;

my $file=$ARGV[0] ? $ARGV[0] : "./alekhine_euwe.pgn" ;

# create the chessboard at the beginning position

my $bd=Board->new() ;
$bd->startgame() ;
$bd->has_moved(status=>$status,ini=>'y') ;

# show the initial status = 
foreach (keys %{$status}){ print "$_  $status->{$_} " ;}

# read the pgn file and split each moves

my $game = Chess::PGN::Parse->new($file);
$game->read_game();

#my @moves = @{$game->smart_parse_game()};
$game->smart_parse_game() ;
my @moves=@{$game->moves()} ; # correction due to perl  5.8.8

#  analyse the position and calculates the number of moves
# avalaible for whites and blacks

foreach (@moves) {

$bd->chessview ;
$bd->bestmove ;

  if ( /O-O-O/ ) {
my $couleur=$currMove % 2 ? 'White' : 'Black' ;
$bd->castling(side=>'Q',status=>$status,couleur=>$couleur );

  } elsif (/O-O/ ) {
my $couleur=$currMove % 2 ? 'White' : 'Black' ;
$bd->castling(side=>'K',status=>$status,couleur=>$couleur );


  } elsif (   /([QKNBR]?)(\d?|\w?)(x?)(\w{1}\d{1})(\+*)/ ) {
    $piece=$1 eq "" ? 'P':$1 ;
    $piece=  $currMove % 2 ? $piece : lc($piece)  ;
    $from=$2 ;
    $take=$3 ;
    $dest=$4 ;
    $check=$5;
    @start=() ;
  }

# look from where the pieces comes from to alleviate multiple initial moves
# means $from contains a row or a file hint

@start= grep { defined ($bd->{$_})&& $piece eq  $bd->{$_} } %{$bd}  ;
  if ($from  ne "") {
    my @filtered=() ;

@filtered= grep {$from =~ /[split('',$_)]/}  @start ;
    @start=@filtered ;
  }

  # check the destination squares

 FIND: foreach my $s (0..$#start) {
    my $set=[] ;
    ## $set is filled with all the valid moves

    $bd->vldmov(row=>chr(vec($start[$s],1,8)),
		col=>chr( vec($start[$s],0,8)),
		piece=>$piece,
		valid=>$set) ;

    foreach my $to (0..$#{$set}) {
      if ($set->[$to] eq  $dest) {
        # asap the destination is found , 
        #the move is played and the loop exited 
	$bd->deletepiece($start[$s]) ;
	$bd->put($piece,$dest) ;
        $ref=$set ;
	last FIND ;
      }
    } 
  }
  my ($nw,$nb)=$bd->chessmovcnt ;
  print "$currMove  $_  blancs=$nw moves noirs=$nb moves \n " ;

# you can verify if kings are checked by uncommented the following
#$bd->is_shaked(king=>'k',out=>'y') ;
#$bd->is_shaked(king=>'K',out=>'y') ;

# the status must be updated  after every moves to be valid
$bd->has_moved(status=>$status) ;

  $currMove++;
}

# check the final position (but not the empty squares)
 $bd->chessview ;

use Test::Simple tests => 14 ;
my %verif=(
  qw( f8 k a7 p b7 p e7 n c6 p e6 B f6 p h6 K g5 P a4 P f4 P
     h4 P c3 r e1 R)) ;
print "\n test \n" ;
map { ok($bd->getpiece($_) eq $verif{$_} ) } keys %verif ;

