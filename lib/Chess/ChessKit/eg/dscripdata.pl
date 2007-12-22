#!/usr/bin/perl -w
####-----------------------------------
### File	: descripdata.pl
### Author	: Ch.Minc
### Purpose	: Translate Descriptive into algebraic notation test Trad.pm
### Version	: 1.1 2007/12/22
### copyright GNU license
####-----------------------------------

=pod

Translate Descriptive into algebraic notation
Use with my own development for Chess

=cut


use strict ;
use Chess::ChessKit::Trad  ;
use warnings ;

our $VERSION = '1.1';
# if not interested by $bd object board create inside dscrip
#use the following instead :  use Trad() ;

my @sauces = <<End_Lines =~ m/(\S.*\S)/g;
1. P-Q4  N-KB3
2. P-QB4 P-B4
3. P-Q5  P-QN4
4. PxP   P-QR3
5. PxP   BxP
6. N-QB3 P-Q3
7. P-KN3 P-N3
8. B-N2  B-KN2
9. N-R3  QN-Q2
10. O-O  O-O
11. Q-B2 Q-R4
12. B-N5 KR-N1
13. KR-K1 R-R2
14. QR-N1 R/2-N2
15. B-Q2  P-B5
16. P-QN4 PxP e.p.
17. RxP   B-B5
18. RxR   RxR
19. N-KN5 Q-R3
20. R-QB1 R-N1
21. B-R3  N-B4
22. B-K3  NxP
23. NxN   BxN
24. BxN   PxB
25. QxBP  BxP
26. QxP   B-B3
27. Q-K3  BxN
End_Lines

# read a game @sauces in descriptive notation return a game in
# long algebraic notation @moves 

my $test =27 ;


# first example

# print the input game list
for my $i (0..$#sauces)  {
my @mv=split(' ',$sauces[$i]) ;
print "@mv  \n" ;}

# translate descriptive to algebaic
my @mouv=&Trad::dscrip(mov=>\@sauces) ;

# print the albrebraic game list
foreach (0..$#mouv) {
  print( "\n", 1+ $_/2,'.')  unless ($_ % 2)  ;
  print "  $mouv[$_]  " ;
}
# get and show the last position
$Trad::bd->chessview ;

# check the final position (but not the empty squares)

use Test::Simple tests => 20 ;
my %verif=(
  qw( a2 b a6 q b8 r c1 R e2 P e3 Q f2 P g5 b f7 p g1 K
      g3 P g6 p g8 k h2 P h3 B h7 p)) ;
print "\n tests results of example 1 of $0 \n" ;
map { ok($Trad::bd->getpiece($_) eq $verif{$_} ) } keys %verif ;


# second example with  promotion testing and edit starting position

#study by Saavedra
#K b6 P c6 k a1 r d5

my %study=('K'=>["b6"],'P'=>["c6"],'k'=>["a1"],'r'=>["d5"]) ;

my @source=<DATA> ;
map(chomp, @source) ;

# translate the game list with an initial position
my @coups=&Trad::dscrip(mov=>\@source,ini=>\%study) ;

# print the last position
$Trad::bd->chessview ;

 # print the input list and the translated one at same time
foreach (0..$#coups) {
  print ( "\n", $source[$_/2],"\t", 1+ $_/2,'.' ,)  unless ($_ % 2)  ;
  print " $coups[$_] " ;
}
 %verif=(
  qw( a1 k a4 r b3 K c8 R)) ;
print "\n tests results of  example 2 of $0 \n" ;
map { ok($Trad::bd->getpiece($_) eq $verif{$_} ) } keys %verif ;
__END__
1. P-B7 R-Q3+
2. K-N5 R-Q4+
3. K-N4 R-Q5+
4. K-N3 R-Q6+
5. K-B2 R-Q5
6. P-B8=R R-QR5
7. K-N3 
