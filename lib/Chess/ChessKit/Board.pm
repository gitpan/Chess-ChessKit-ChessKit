#!/usr/bin/perl -w
####-----------------------------------
### File	: Board.pm
### Author	: Ch.Minc
### Purpose	: Package for ChessKit
### Version	: 1.2 2007/02/22
### copyright GNU license
####-----------------------------------

package Board ;

#package Chess::ChessKit::Board;

use warnings;
use strict;
use Chess::ChessKit::Move   ;


=head1 NAME

ChessKit::Board 

=head1 VERSION

Version 1.2

=cut

=head1 SYNOPSIS

see ChessKit

=head1 FUNCTIONS

=head2 sub bestmove

Get the Best move as TMN means
see ChessKit

=head2 sub boardcopy

see ChessKit

=head2 sub can_castling

see ChessKit

=head2 sub cantake

see ChessKit

=head2 sub castling

see ChessKit

=head2 sub chessmovcnt

see ChessKit

=head2 sub chessmovcntint

see ChessKit

=head2 sub chessview

see ChessKit

=head2 sub deletepiece

see ChessKit

=head2 sub getpiece

see ChessKit

=head2 sub has_moved

see ChessKit

=head2 sub is_shaked

see ChessKit

=head2 sub new

see ChessKit

=head2 sub print

see ChessKit

=head2 sub put

see ChessKit

=head2 sub startgame

see ChessKit

=head2 sub valid

see ChessKit

=head2 sub vldmov

see ChessKit

=head2 sub genfen

see ChessKit

=head2 getfen

see ChessKit

=cut

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

# NOTE: piece means any chess piece or pawn
# NOTE  Blacks are designed by lower case letters and Whites by upper ones

# Board means here the chessboard with the pieces on it.
# The object here hereafter is nothing more that the position
# of pieces on their sqares.

# pieces are in upper case for Whites and lower case for Blacks
# as usually written in FEN

our $VERSION = '1.1' ;



sub new {
  my ($class,@args)=@_ ;
  my $self={} ;
  return bless ($self,$class) ;
}

sub startgame {
  # initial starting position of the game
  #usage $self->startgame(%position)

  my ($self,%arg)=@_ ;
  %{$self}=() ;
  my %poset=(
	     'K'=>["e1"],
	     'k'=>["e8"],
	     'Q'=>["d1"],
	     'q'=>["d8"],
	     'R'=>[qw(a1 h1)],
	     'r'=>[qw(a8 h8)],
	     'B'=>[qw(c1 f1)],
	     'b'=>[qw(c8 f8)],
	     'N'=>[qw(b1 g1)],
	     'n'=>[qw(b8 g8)],
	     'P'=>[qw(a2 b2 c2 d2 e2 f2 g2 h2)],
	     'p'=>[qw(a7 b7 c7 d7 e7 f7 g7 h7)]
	    ) ;
  %poset=%arg ?%arg :%poset ;
  foreach my $p (qw(K Q R N B P k q r n b p)) {
    foreach (@{$poset{$p}}) {
      $self->put($p,$_) ;
    }
  }

}

sub put {
  # place a piece on the board
  my($self,$piece,$location)=@_ ;
  $$self{$location}=$piece ;
}

sub print {
  # print the position of the pieces
  my($self)=@_ ;
  foreach (keys %{$self}) {
    print " loc= $_  piece=$$self{$_} \n" ;
  }
}

  sub boardcopy {
    my ($self,$bddest)=@_ ;
    %{$bddest}=() ;
    %{$bddest}=%{$self} ;
  }
sub getpiece{
  my($self,$loc)=@_ ;
  return ($$self{$loc} ) ;
}

sub deletepiece{
  my($self,$loc)=@_ ;
  delete $$self{$loc} ;
}

sub chessview {
  my $self=shift ;
  print "\n" ;
  my @alpha=qw(a b c d e f g h) ;
  my @digit=qw(8 7 6 5 4 3 2 1) ;
  foreach my $num (@digit) {
    foreach my $let (@alpha) {
      my $p=$$self{$let.$num} ;
      print defined($p) ? $p : "." , " " ;
    }
    print "\n" ;
  }
  print "\n" ;
}

sub cantake{

  #usage $self->cantake(who=>'Q',where=>'h8')

  my ($self,%arg)=@_ ;
  my $piece=$arg{who} ;
  my $where=$arg{where} ;

  my %color=(qw /B 0 K 0 N 0 P 0 Q 0 R 0 U 0 b 1 k 1 n 1 p 1 q 1 r 1 u 1/ ) ;
  # U,u is used for pawn taking
  my $wanted=$self->getpiece($where) ;
  if (defined($wanted) && ($color{$piece} != $color{$wanted} )) {
    return $wanted ;
  } else {
    return "no" ;
  }
}

sub valid{
  # check valid moves
  my ($self,%arg)=@_ ;
  my $caval=$arg{mov} ;
  my $set=$arg{valid} ;
  my $piece=$arg{piece} ;

  my $i=0 ;
  for (  my $m=0 ; $m<=7 ;  $m++ ) {
    if (defined( @{$caval->[$m]})) {
      foreach (0..$#{$caval->[$m]}) {
	my $c= $caval->[$m][$_];
	my $p=$self->getpiece($c) ;
	# pawn catching
	if ($piece =~/U/i) {
	  $set->[$i++]=$c if ( $self->cantake(who=>$piece,where=>$c) ne "no" ) ;
	  last ;
	}
	if ( !defined($p) ) {
	  $set->[$i++]=$c ;
	} elsif ($piece =~/P/i) {
	  last ;
	} elsif ( $self->cantake(who=>$piece,where=>$c) eq "no") {
	  last ;
	} else {
	  $set->[$i++]=$c ; last ;
	}
      }
    }
  }
}



sub vldmov{

  my %default=(qw/recur yes/ ) ;
  my ($self,%arg)=@_ ;
  %arg=(%default,%arg) ;

  my $set=$arg{valid} ;
  my $piece=$arg{piece} ;
  my $num=$arg{row} ;
  my $let=$arg{col} ;
  my $control=$arg{recur} ;
  my $caval=[[]] ;
  $Move::gmv{$piece}(row=>$num-1, col =>ord($let)-ord('a'),mov=>$caval,color=>$piece) ;
  $self->valid(valid=>$set,mov=>$caval,piece=>$piece) ;

  # Treat the Pawn move as a special piece called U when capture

  if ($piece =~ /P/i) {
    my $upiece=($piece =~ /P/) ? 'U':'u' ;
    $caval=[[]] ;
    $Move::gmv{$upiece}(row=>$num-1, col =>ord($let)-ord('a'),mov=>$caval,color=>$upiece) ;
    my $uset=[] ;
    $self->valid(valid=>$uset,mov=>$caval,piece=>$upiece) ;
    @{$set}=(@{$set},@{$uset}) ;
  }
  return if ($control eq 'no') ;

  # a valid move is without check
  # if king is checked and no move without checks means mat
  # if king is w/o     and no move again   "       "    pat but


  my $uset=[] ;
  my $chkbd=Board->new() ;
  my $king= $piece =~ /[QKNBRPU]/ ? 'K':'k' ;
  foreach my $to (0..$#{$set}) {
    $self->boardcopy($chkbd) ;
    $chkbd->deletepiece($let.$num) ;
    $chkbd->put($piece,$set->[$to]) ;
    if ($chkbd->is_shaked(king=>$king,out=>'n') ne 'yes') { 
      push(@{$uset},$set->[$to]) ;
    }
  }
  @{$set}=(@{$uset}) ;
}

sub chessmovcnt{
  # scan the board and count the valid moves
  # not removed for sake of backward compatibility
  # replaced by chessmovcnt
  my ($self,%arg)=@_ ;

  my %sum=('w'=>0,'b'=>0) ;

  foreach my $num (reverse 1..8) {
    foreach my $let ('a'..'h') {
      my $p=$$self{$let.$num} ;
      if (defined($p)) {
	my $set=[] ;
	$self->vldmov(row=>$num, col=>$let,piece=>$p,valid=>$set) ;
	$p =~ /[BKNPQR]/ ? ( $sum{w} +=@{$set}) :($sum{b} +=@{$set} ) ;
      }
    }
  }
  return ($sum{w},$sum{b}) ;
}

sub chessmovcntint{
  # scan the board and count the valid moves
  my ($self,%arg)=@_ ;

my %sum=('w'=>[],'b'=>[]) ;

  foreach my $num (reverse 1..8) {
    foreach my $let ('a'..'h') {
      my $p=$$self{$let.$num} ;
      if (defined($p)) {
	my $set=[] ;
	$self->vldmov(row=>$num, col=>$let,piece=>$p,valid=>$set) ;
	$p =~ /[BKNPQR]/ ? (push @{$sum{w}}, @{$set}) :(push @{$sum{b}},@{$set} ) ;
      }
    }
  }
return %sum ;
}

sub bestmove{
  my ($self)=@_ ;
  # parameters  w or b
  my %bm ;		     
  foreach my $loc (sort keys %{$self} ) {
    my $piece=$self->{$loc} ;
    my ($let,$num)=split('',$loc) ;
    my $set=[] ;
    $self->vldmov(row=>$num, col=>$let,piece=>$piece,valid=>$set) ;
    my $size=@{$set} ;
    foreach my $try (@{$set}) {
      my $capture=$self->{$try} ;
      $self->deletepiece($loc) ;
      $self->put($piece,$try) ;
      my $bset=[] ;
      my($sumw,$sumb)=$self->chessmovcnt ;
      $bm{$piece}{$loc}{$try}{'w'}=$sumw;
      $bm{$piece}{$loc}{$try}{'b'}=$sumb;
      defined($capture) ? $self->put($capture,$try):$self->deletepiece($try) ;
      $self->put($piece,$loc) ;
    }
  }
  my %max ;
  my %min ;
  #return $bm ;
  foreach my $color ('w','b') {
    my $max=0 ;
    my $min=1000 ;
    foreach my $piece (keys %bm) {
      foreach my $where (keys %{$bm{$piece}} ) {
	foreach my $to (keys %{$bm{$piece}{$where}} ) {

	  my $value= $bm{$piece}{$where}{$to}{$color} ;
	  $max=$max > $value ? $max : $value ;
	  $min=$min < $value ? $min : $value ; 
	}
      }
    }
    $max{$color}=$max ;
    $min{$color}=$min ;
  }
  #print the min & max
  foreach my $color ('w','b') {
    foreach my $piece (keys %bm) {
      foreach my $where (keys %{$bm{$piece}} ) {
	foreach my $to (keys %{$bm{$piece}{$where}} ) {

	  my $value= $bm{$piece}{$where}{$to}{$color} ;
	  if ( ($value == $min{$color}) || ($value == $max{$color}) ) {
	    print " $piece from $where to $to give for $color :",$value,"\n" ;
	  }
	}
      }
    }
  }
}

sub is_shaked {
  my ($self,%arg)=@_ ;
  my $king=$arg{king} ;
  my $out=$arg{out} ;

  my $diag="" ;
  my $locking ;

  # where is the king
  foreach ( keys %{$self} ) {
    if ($king eq $self->{$_}) {
      $locking=$_ ; last ;
    }
  }
  my $color=$king =~/K/ ? "qknbrpu" : "QKNBRPU" ;
  foreach my $loc ( keys %{$self} ) {
    my $piece=$self->{$loc} ;
    if ($piece =~ /[$color]/) { 
      my ($let,$num)=split('',$loc) ;
      my $set=[] ;
      $self->vldmov(row=>$num, col=>$let,piece=>$piece,valid=>$set,recur=>'no') ;
      my $size=@{$set} ;
      #    for debug
      #    foreach (0..$#{$set}){
      #    print " $king is shaked by $piece at $loc \n" if ($locking eq $set->[$_]) ;}
      # conditional outputting by flag $out='y' 
      foreach (0..$#{$set}) {
	if ( defined( $set->[$_]) && ($locking eq $set->[$_]) ) {
	  $diag='yes' ;
	  print " $king is shaked by $piece at $loc \n" if ($out eq 'y') ;
	  # note: "shake" is a joke written here in place of "check" after a while writing this, ouf!
	}
      }
    }
  }
  return $diag ;
}


sub has_moved {

  # set the status of Rook and king to know if they are
  # always at there original place
  # must be called after every moves

  my ($self,%arg)=@_ ;
  my $status=$arg{status} ;
  my %default= (qw/ini no/) ;
  %arg=(%default,%arg) ;

  %{$status}=( qw/KK no  kk no KR no QR no kr no qr no/) if ($arg{ini} eq 'y') ;
  my %hereis=qw(KK e1 kk e8 KR h1 QR a1 kr h8 qr a8) ;

  foreach my $piece (keys %hereis ) {
    my $p=substr($piece,1,1) ;
    my $q=defined($self->{$hereis{$piece }}) ? $self->{$hereis{$piece }}:"rien" ;
    $status->{$piece}= 
      ( $p eq $q ) &&  ($status->{$piece} eq 'no') ? 'no' : 'yes' ;

  }

}

sub castling{
  my ($self,%arg)=@_ ;
  my $couleur=$arg{couleur} ;
  my $side=$arg{side} ;
  my $status=$arg{status} ;
  my $out=$arg{out}?$arg{out}:'no'  ;


  my ($la,$Kk,$Rr,$babor)=$couleur eq 'White' ? (1,'K','R', $side) : (8,'k','r',lc($side) ) ;
  my @rank = $side eq 'K' ? (qw/e h g f/): (qw/e a c d/) ;

  $self->can_castling(roq=>$babor . $Kk,status=>$status,out=>$out) ne 'no' or die " castling move is wrong" ;

  $self->deletepiece($rank[0].$la ) ;
  $self->deletepiece($rank[1].$la ) ;
  $self->put($Kk,$rank[2].$la) ;
  $self->put($Rr,$rank[3].$la) ;

  return ;

}


sub can_castling {

  # return $diag and if $diag = 'no' means: castling could not be done
  my ($self,%arg)=@_ ;
  my $roq=$arg{roq} ;
  my $status=$arg{status} ;
  my $out=$arg{out}?$arg{out}:'no'  ;
  my $diag="yes" ;

  # setting conditions
  # Are the king and rook at their initial position (special) with no moves ($status)
  # status  (ep,wkr,wqr,,K,bkr,bqr,k)
  # KK for white King(K) King side castling (K) and so on.

  my %cds=(
	   KK=>[qw(KK KR V1 V2)],
	   QK=>[qw(KK QR V3 V4)],
	   kk=>[qw(kk kr v1 v2)],
	   qk=>[qw(kk qr v1 v2)]) ;

  my %special=
    qw(KK e1 V1 f1 V2 g1 V3 d1 V4 c1 kk e8 v1 f8 v2 g8 v3 d8 v4 c8 KR h1 QR a1 kr h8 qr a8) ;

  my $resu=( $status->{ $cds{$roq}->[0]} eq 'no') &&
    ( $status->{ $cds{$roq}->[1]} eq 'no') &&
      (!defined $self->{ $special{$cds{$roq}->[2]} } ) &&
	(!defined $self->{ $special{$cds{$roq}->[3]} } ) ;

  return $diag='no' unless ($resu) ;

  # then is it in "checks" because of the virtual king move during castling ?

  my $color=$cds{$roq}->[0] =~/KK/ ? "qknbrpu" : "QKNBRPU" ;
  my @locking=( $special{$cds{$roq}->[0]}, $special{$cds{$roq}->[1]}, $special{$cds{$roq}->[2]} ) ;

  foreach my $loc ( keys %{$self} ) {
    my $piece=$self->{$loc} ;
    if ($piece =~ /[$color]/) { 
      my ($let,$num)=split('',$loc) ;
      my $set=[] ;
      $self->vldmov(row=>$num, col=>$let,piece=>$piece,valid=>$set,recur=>'no') ;
      my $size=@{$set} ;
      #    foreach (0..$#{$set}){
      #    print " $king is shaked by $piece at $loc \n" if ($locking eq $set->[$_]) ;}
      foreach (0..$#{$set}) {
        foreach my $l (0..2) {
	  if ( defined( $set->[$_]) && ($locking[$l] eq $set->[$_]) ) {
	    $diag='no' ;
	    print " roq is shaked by $piece at $loc \n" if ($out eq 'yes') ;
	  }
	}
      }
    }
  }
  return $diag ;
}

sub getfen {

# translate from the fen string $fen
# to a hash reference $posini used
# as initialisation for the game

# work with pointers $posini & $status

my $self=shift ;
my $fen=shift ;
my $posini=shift ;
my $status=shift ;

  my @fields=split ' ', $fen ;
# reinitialisation of the chessboard means reset of :
  %{$posini}=() ;
  # extended empty squares with '-'
  $fields[0] =~ s/(\d)/'-'x $1/ge ;

  # delete useless '/'
  $fields[0] =~ s!/!!g ;
  my @pospck=split '',$fields[0] ;

  # suppose le string bien forme
  $#pospck == 63 or die ("**** fen mal formé ($#pospck)  **** \n") ;

 COL:for (reverse 1..8){
  ROW:for my $rank ('a'..'h'){ 
      my $piece=shift @pospck ;
      push( @{${$posini}{$piece}} ,$rank . $_) unless ($piece eq '-') ;
    }
  }
# except status others values are not in use .
#   shift @fields ;
# my $colmove=shift @fields ;
  my $fenstat=$fields[2] ;
#  my $ep=shift @fields ;
#  my $ply=shift @fields ; 
#  my $nmove=shift @fields ;

($fenstat =~ /K/) ?( $status->{KR}='no'): ($status->{KR}='yes') ; 
($fenstat =~ /Q/) ? ($status->{QR}='no') : ($status->{QR}='yes') ; 
($fenstat =~ /k/) ? ($status->{kr}='no'): ($status->{kr}='yes') ; 
($fenstat =~ /q/) ? ($status->{qr}='no'): ($status->{qr}='yes') ; 

#don't know which ones, of the king or the rook, has moved
# assume it's only the rook for sake of simplicity
$status->{KK}='no' ;
$status->{kk}='no' ;  
}

sub genfen {
# generate the fen from the current board
# parameters $objet,$move color('w',-,'b'),$roque status
# $ep en passant , $ply ply count, $move number
  my $self=shift ;
  my $colmove=shift ;
  my $status=shift ;
  my $ep=shift ;
  my $ply=shift ; 
  my $nmove=shift ;
 
  my $fen ;
  foreach my $num (reverse 1..8) {
    foreach my $let ('a'..'h') {
      my $p=$$self{$let.$num} ;
      $fen .= defined($p) ? $p : "."  ;
    }
    $fen .='/' unless $num ==1;
  }
  $fen=~ s/(\.+)/length($1)/eg ;

my $fenstat .=($status->{KK} eq 'yes' || $status->{KR} eq 'yes') ? "" : "K" ;
$fenstat .=($status->{KK} eq 'yes' || $status->{QR} eq 'yes') ? "": "Q" ;
$fenstat .=($status->{kk} eq 'yes' || $status->{kr} eq 'yes') ? "": "k" ;
$fenstat .=($status->{kk} eq 'yes' || $status->{qr} eq 'yes') ? "" : "q" ;
$fenstat ="-" unless  length($fenstat) ;
print " genfen $fenstat \n" ; 
  return ($fen . ' ' . $colmove . ' ' . $fenstat . ' '. $ep .' ' . $ply .' ' . $nmove );
}

1;
