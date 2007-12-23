#!/usr/bin/perl -w
####-----------------------------------
### File	: Move.pm
### Author	: Ch.Minc
### Purpose	: Package for ChessKit
### Version	: 1.1 2005/8/10
### copyright GNU license
####-----------------------------------

package Move ;
#package Chess::ChessKit::Move;

use warnings;
use strict;

our $VERSION = '1.1';

=head1 NAME

ChessKit::Move

=head1 VERSION

Version 1.1

=cut

=head1 SYNOPSIS

see ChessKit

=cut

# remainder How are built the moves
#tour
#iter=>7 dir =>3
#my @inc_l=(0,0,-1,1) ;
#my @inc_c=(-1,1,0,0) ;

#fou 
#iter=>7 dir =>3
#my @inc_l=(1,1,-1,-1) ;
#my @inc_c=(1,-1,-1,1) ;

#cavalier 
#iter=>0 dir =>7
#my @inc_l=(-2,-2,2,2,-1,1,-1,1) ;
#my @inc_c=(-1,1,-1,1,-2,-2,2,2) ;

#dame= fou+tour
#iter=>7 dir =>3

#roi=fou+tour
#iter=>0 dir =>3

#pion
#iter=>1 dir =>1
#my @inc_l=(0) ;
#my @inc_c=(1) ;

#iter=>0 dir =>1 cds prise
#my @inc_l=(1,1) ;
#my @inc_c=(1,-1) ;

#en_passant
#alpha7-alpha5 || alpha2-alpha4

#queenroq
#states a1 || a8 && king + echec c1-d1-e1
#kingroq
#states h1 || h8 && king + echec       e1-f1-g1

require Exporter ;


use vars qw(
            @ISA
            @EXPORT );
@ISA =qw(Exporter) ;

@EXPORT = qw( %gmv  );

our  %gmv=(
	   n=>\&Knight,
	   r=>\&Rook,
	   b=>\&Bishop,
	   q=>\&Queen,
           p=>\&Pawn,
	   k=>\&King,
           u=>\&PawnCatch,
	   N=>\&Knight,
	   R=>\&Rook,
	   B=>\&Bishop,
	   Q=>\&Queen,
	   P=>\&Pawn,
	   K=>\&King,
           U=>\&PawnCatch) ;

=head2 sub Rook

get the move of the Rook

=cut

sub Rook{
  my %default=(qw/row 0 col 0 lim 7 dir 3/,
	       inc_l => [0,0,-1,1],
	       inc_c=>[-1,1,0,0] ) ;
  my %arg=@_ ;
  %arg=(%default,%arg) ;

  lookup(%arg) ;

}

=head2 sub Bishop

get the move of the Bishop

=cut

sub Bishop{
my %default=(qw/row 0 col 0 lim 7 dir 3/,
             inc_l => [1,1,-1,-1],
             inc_c=>[1,-1,-1,1]) ;
my %arg=@_ ;
%arg=(%default,%arg) ;

lookup(%arg) ;

}

=head2 sub Queen

get the move of the Queen

=cut

sub Queen{

my $arr1=[[]] ;
my %arg=@_ ;
my $mov=$arg{mov} ;


$arg{mov}=$arr1 ;
Bishop(%arg) ;

foreach (0..3){
push( @{$mov->[$_]}, @{$arr1->[$_]} ) if (defined( @{$arr1->[$_]})) ;
}

my $arr2=[[]] ;
$arg{mov}=$arr2 ;
Rook(%arg) ;
foreach (0..3){
push( @{$mov->[$_+4]}, @{$arr2->[$_]} ) if (defined( @{$arr2->[$_]})) ;
}
}

=head2 sub King

get the move of the King

=cut

sub King{

my %default=(lim=>0) ;
my %arg=@_ ;
%arg=(%default,%arg) ;

Queen(%arg) ;


}

=head2 sub Knight

get the move of the Knight

=cut

sub Knight{
my %default=(qw/row 0 col 0 lim 0  dir 7/,
             inc_l => [-2,-2,2,2,-1,1,-1,1],
             inc_c=>[-1,1,-1,1,-2,-2,2,2] ) ;
my (%arg)=@_ ;
%arg=(%default,%arg) ;

lookup(%arg) ;

}

=head2 sub Pawn

get the move of the Pawn

=cut

sub Pawn{

my %default=(qw/row 1 col 0 lim 1  dir 0 color P/,
             inc_l => [1],
             inc_c=>[0] ) ;
my (%arg)=@_ ;
if($arg{color} eq 'p') {
$arg{inc_l}=[-1] ;
$arg{lim}=0 if $arg{row} != 6 ;} 
else{ $arg{lim}=0 if $arg{row} != 1 ;} 
%arg=(%default,%arg) ;

lookup(%arg) ;
return ;
}

=head2 sub PawnCatch

get the move of the PawnCatch

=cut

sub PawnCatch{
# can_take + e.p. ?
my %default=(qw/row 1 col 0 lim 0  dir 1 color U/,
             inc_l =>[1,1],  #color -1,-1
             inc_c=>[1,-1] ) ;

my (%arg)=@_ ;
if($arg{color} eq 'u') {
$arg{inc_l}=[-1,-1] ;}
%arg=(%default,%arg) ;
lookup(%arg) ;
}



=head2 sub lookup

generate the move datas

sub lookup{

   row=>'numeric', col =>' numeric , lim=>'limite de mouvement',
   dir => 'nombre de direction',mov=>'ref avec les cases[dir][]'
}

=cut

sub lookup{

  my %arg=@_ ;

  my $row=$arg{row} ;
  my $col=$arg{col} ;
  my $iter=$arg{lim} ;
  my $dir=$arg{dir} ;
  my $mov=$arg{mov} ;
  my @inc_c=@{$arg{inc_c}} ;
  my @inc_l=@{$arg{inc_l}} ;

  my $l ;
  my $c ;

  for (  my $j=0 ; $j<=$dir ; $j++) {
    my $k=0 ;			

    do  {
      $l=$col+ $inc_c[$j]*($k+1);
      $c= $row + $inc_l[$j]*($k+1)  ;
      $mov->[$j][$k]=chr(ord('a')+$l).($c+1) if ( $l >=0 && $l <=7 && $c >=0 && $c <=7 ) ;
      $k++ ;
    }
      until ($k > $iter || $l <0 || $l > 7 || $c < 0 || $c > 7 ) ;
  }
}

=head1 AUTHOR

Charles Minc, C<< <charles.minc@wanadoo.fr> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-chesskit-board@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ChessKit>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 Charles Minc, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut


1;


