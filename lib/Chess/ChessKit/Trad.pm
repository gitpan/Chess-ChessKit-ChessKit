 #!/usr/bin/perl -w
 ####-----------------------------------
 ### File	: Trad.pm
 ### Author	: C.Minc
 ### Purpose	: chess translator
 ### Version	: 1.1 2007/12/22
 ### copyright GNU license
 ####-----------------------------------


package Trad ;

#package Chess::ChessKit::Trad ;

use warnings;
use strict;

=head1 NAME

ChessKit::Trad

=head1 VERSION

Version 1.1

=cut

=head1 SYNOPSIS

see ChessKit

=head1 FUNCTIONS

=head2 sub dscrip

see ChessKit

=head2 sub mauv

retrieve the move from notation
see ChessKit

=head2 sub promote

retrieve the element of pawn promotion
see ChessKit

=head2 sub resolve

resolve move ambiguity of the destination square
see ChessKit

=head2 sub resolve_deb

resolve move ambiguity of the starting square
see ChessKit

=head2 sub trad

High level interface for translating notation
from languages
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

our $VERSION = '1.0' ;

use strict ;
use Symbol ;
use Chess::ChessKit::Board  ;


require Exporter ;

use vars qw(
            @ISA
            @EXPORT
             );
our @ISA =qw(Exporter) ;

our @EXPORT = qw( %country $bd );

# this part concerns only algrbraic notation

our %country=(
Czech       =>'Czech     ',
Danish      =>'Danish    ',
Dutch       =>'Dutch     ',
English     =>'English   ',
Estonian    =>'Estonian  ',
Finnish     =>'Finnish   ',
French      =>'French    ',
German      =>'German    ',
Hungarian   =>'Hungarian ',
Icelandic   =>'Icelandic ',
Italian     =>'Italian   ',
Norwegian   =>'Norwegian ',
Polish      =>'Polish    ',
Portuguese  =>'Portuguese',
Romanian    =>'Romanian  ',
Spanish     =>'Spanish   ',
Swedish     =>'Swedish   ') ;


sub trad {
    (my $fileresult, my $file, my $lang ,my $lang2)=@_ ;

my %trad2eng=(
Czech       =>'JSVDK',
Danish      =>'SLTDK',
Dutch       =>'PLTDK',
English     =>'NBRQK',
Estonian    =>'ROVLK',
Finnish     =>'RLTDK',
French      =>'CFTDR',
German      =>'SLTDK',
Hungarian   =>'HFBVK',
Icelandic   =>'RBHDK',
Italian     =>'CATDR',
Norwegian   =>'SLTDK',
Polish      =>'SGWHK',
Portuguese  =>'CBTDR',
Romanian    =>'CNTDR',
Spanish     =>'CATDR',
Swedish     =>'SLTDK') ;

print "from $lang to $lang2\n " ;
my $piece=$trad2eng{$lang} ;
my $prom=substr($piece,0,4) ;
my @ltr=split( // ,$piece );
my @ltr2=split( // ,$trad2eng{$lang2} );

my %trad2en=("" => "", $ltr[0] => $ltr2[0],  $ltr[1] => $ltr2[1],  $ltr[2] => $ltr2[2],  $ltr[3] => $ltr2[3], $ltr[4] => $ltr2[4]) ;

    open(OFILE,">",$fileresult) ;

    open(HFILE,$file) or die "cannot open file $file  ";
    my @line=<HFILE> ;

foreach (@line) {

# because we can find also something like that :3. d4, cxd4 ; 4. Cxd4, e5; 5. Cdb5, Cf6 ;
 s/([$piece]?)([a-h]?[1-8]?\s*x?\s*[a-h][1-8][\+#]?\s*)(?:[,;]*)(\s*\=?\s*)([$prom]?)/$trad2en{$1}$2$3$trad2en{$4}/g ;

# piece  ^^
# column or line ^^^  ^^^
# capture                     ^ 
#  destination square               ^^^  ^^^
#  promotion                                                                 ^^^
#

# just as above to delete semi-colons and commas
s/([O-]?O-O\s*)(?:[,;]*)/$1/g ;

print OFILE $_ ;
    }

    close(HFILE) ;
    close(OFILE) ;
    return ;
}


# the following part concerns only english descriptive notation

my @from ,
my @to ;
my $status={} ;			# used to valid castling
my @moves ;
our $bd ;


# this array below is used to reverse the column numbering of the Black moves
my @black=(0,8,7,6,5,4,3,2,1) ;

# the following make the correspondance of the row naming between 
# descriptive and algebraic notation

my %algebra=(QR=>'a',
	     QN=>'b',
	     QB=>'c',
	     Q=> 'd',
	     K=> 'e',
	     KB=>'f',
	     KN=>'g',
	     KR=>'h') ;

sub dscrip {

my (%arg)=@_ ;
my @sauces=@{$arg{mov}} ;
my %study=%{$arg{ini}}if ( defined($arg{ini})) ;
@moves=() ;

# read a game @sauces in descriptive notation return a game in
# long algebraic notation @moves
# chess is initialized with %study if nothing usual initial chess game position
# usage:
#@array_of_moves=&Trad::dscrip(ini=>ref_someposition or not,
#                              mov=>ref_set_of_moves)


$bd=Board->new() ;
$bd->startgame(%study) ;
$bd->has_moved(status=>$status,ini=>'y') ;

# for debug
#$bd->chessview ;

# main loop to translate notation

for (my $i=0; $i<=$#sauces ; $i++) {

# parse the white & black moves



#  $sauces[$i]=~ /(\d*\.)\s*(O|\w*\/?\d?)(-|x)([PQKNBR|O-O|O]*)(\d)?\s*(ch|e\.p\.|\([QNBR]\)|=\s*[QNBR])?\s*(O|\w*\/?\d?)(-|x)([PQKNBR|O-O|O]*)(\d)?\s*(ch|e\.p\.|\([QNBR]\)|=[QNBR])?\s*/ ;
#  #                 1         2           3          4          5               6                 7            8          9           10                   11



my $cnt=$sauces[$i]=~ tr/-x/-x/ ;
my $pattern=qr/\s*(O|\w*\/?\d?)(-|x)([PQKNBR|O-O|O]*)(\d)?\s*(ch|e\.p\.|\([QNBR]\)|=\s*[QNBR])?/ x $cnt  ;
$sauces[$i]=~ /(\d*\.)$pattern\s*/ ;

  my $n=$1 ;
  my $wpiece=$2 ;
  my $waction=$3 ;
  my $wdestalpha=$4 ;
  my $wdestnum=$5 ? $5 : "";
  my $wechec=$6 ? $6 : "" ;
# for debug
#  print "splitting results: $n $wpiece $waction $wdestalpha $wdestnum $wechec " ;
  mauv($bd,'White',$wpiece ,$waction ,$wdestalpha, $wdestnum ,$wechec) ;

#  my $bpiece=$7 ;
#  my $baction=$8 ;
#  my $bdestalpha=$9 ;
  my $bpiece= $cnt==2  ? $7 : ""; 
  my $baction= $cnt==2 ? $8 : ""; 
  my $bdestalpha= $cnt==2 ? $9 : "";
  my $bdestnum=$10 ? $10 : "";
  my $bechec=$11 ? $11 : "" ;

# for debug
if($cnt == 2){
#  print "$bpiece $baction $bdestalpha $bdestnum $bechec \n" ;
  mauv($bd,'Black',$bpiece ,$baction ,$bdestalpha ,$bdestnum ,$bechec) ;}

#print $n ;
}
  
# for debug
#$bd->chessview ;

return @moves ;


sub mauv{
  my $bd=shift ;
  my ($color,$wpiece, $waction, $wdestalpha, $wdestnum ,$wechec)=@_ ;

  @from=() ;
  @to=() ;

  # find the set of pieces for the start of the moves


  my $fpiece= $wpiece ;
  my $roq=$wpiece .  $waction .  $wdestalpha ;

  if ( $roq =~ /O-O-O/ ) {

    $bd->castling(side=>'Q',status=>$status,couleur=>$color );
    push(@moves,$roq) ;
    return ;
  } elsif ( $roq =~/O-O/ ) {

    $bd->castling(side=>'K',status=>$status,couleur=>$color );
    push(@moves,$roq) ;
    return ;

  } elsif ($fpiece =~ /^[PKQRBN]$/ ) { 
@from=grep { $color eq 'White'? $fpiece eq $bd->{$_} :  lc $fpiece eq $bd->{$_} }  (keys %{$bd})  ;
  } else {
    $fpiece=&resolve_deb($color,$wpiece,$waction, $wdestalpha, $wdestnum ,$wechec) ;
  }
  # find the set of possible arrival cases

  if (!defined ($algebra{$wdestalpha} )) {
    &resolve($bd,$color,$wpiece,$waction, $wdestalpha, $wdestnum ,$wechec) ;
  } else {
    my $exp= $algebra{$wdestalpha} ;
    my $num=$color eq 'White' ? $wdestnum : $black[$wdestnum] ;
    push @to,$exp .  $num ;

    my $exp2=( ($wpiece eq 'P') ? "" : ( (length($wpiece) == 2) ? substr( $wpiece,1,1) : $wpiece  ))  .  $exp . $num ;

  }
# for debug
#  print  "**from ", @from , "## to ", @to ,"\n";

  # select the right move(s)


  foreach my $f (0..$#from) {
    foreach my $t (0..$#to) {
      my $set=[] ;
      ## $set contient tous les coups valides (sans echec donc)
      my $tpiece=$color eq 'White'  ? $fpiece : lc($fpiece) ;
      $bd->vldmov(row=>chr(vec($from[$f],1,8)),
		  col=>chr( vec($from[$f],0,8)),
		  piece=>$tpiece,
		  valid=>$set) ;

      foreach (0..$#{$set}) {    
	if ($set->[$_] eq  $to[$t]) {
	  # asap la case de destination est trouvée le coup est joué
	  my $hadak= uc($tpiece) . $from[$f] ;
	  $hadak .= (defined($bd->getpiece($to[$t])) ? 'x' :'-' ) . $to[$t];
	  $hadak=~ s/P//g  ;
          ($tpiece,my $promo)=&promote($tpiece,chr(vec($to[$t],1,8)),$wechec) ;
	  push(@moves,$hadak . $promo) ;
	  $bd->deletepiece($from[$f]) ;
	  $bd->put($tpiece, $to[$t]) ;
#          for debug
#	  $bd->chessview ;
	  last  ;
	}
      }
    }
  }

  return ;
}

sub resolve{
  my $bd=shift ;
  my ($color,$wpiece,$waction, $wdestalpha, $wdestnum ,$wechec)=@_ ;

  # resout les ambiguités

  # prise en passant
  if ($wechec eq 'e.p.') {
    my %pred=(a=>'',b=>'a',c=>'b',d=>'c',e=>'d',f=>'e',g=>'f',h=>'g') ;
    my %suiv=(a=>'b',b=>'c',c=>'d',d=>'e',e=>'f',f=>'g',g=>'h',h=>'') ;
    my @ep ;

    my ( $c,$pion)= $color eq 'White'? ('Black','p'): ('White','P') ;
    my $cto=$color eq 'White' ? '5' : '4' ;
    my $n=$moves[$#moves] ; 
    my ($col,$row)=split('',substr( $n,-2) ) ;
    push @to, $c eq 'White' ? $col . '3' : $col . '6' ;

    foreach (@from) {
      if ( ($_ eq $pred{$col}.$cto ) || ($_ eq  $suiv{$col}.$cto )) {
	push @ep , $_ ;
      }
    }
    # ep entre 1 et 2 mais $#to=0 max 
    if (@ep >= 1) { 
      @from=@ep ;
      # pas propre à ce niveau mais efficace

      $bd->deletepiece($col.$row) ;
      $bd->put($pion, $to[0]) ;

      return ;
    } else {
      print "erreur sur ep", @ep, "\n" ;
      return ;
    }
  }

  # ambiguité de cote K or Q 
  if ($wdestalpha=~ /^[BRN]$/ && $wdestnum ne '') {
    my $num=($color eq 'White' ? $wdestnum : $black[$wdestnum]) ;
    push @to ,$algebra{'K' . $wdestalpha} .  $num ;
    push @to ,$algebra{'Q' . $wdestalpha} .  $num ;
    return ;
  }

  # ambiguité prise de piece
  if ($wdestalpha=~ /^[BRNP]$/ && $waction eq 'x') {
    my $tpiece=$color eq 'White' ? lc($wdestalpha) :uc($wdestalpha) ;
    foreach my $loc (keys %{$bd}) {
      if ($bd->{$loc} eq $tpiece ) {
	push @to,$loc;
      }
      ;
    }

    return ;
  }

  # ambiguité prise de pion
  #  /[QK|][BRN]P/
  if ($wdestalpha=~ /^[BRN]P$/ && $waction eq 'x') {
    my $opp=$color eq 'White' ? 'p' :'P' ;
    foreach my $sq (keys %{$bd}) {
      my $piece= $bd->{$sq} ;
      my $rk=substr($sq,0,1) ;
      if ($piece eq $opp ) {
	my $wx ;
	if ($wdestalpha=~ /^([BRN])P$/ ) { 
	  my $wx=$1 ;
	  foreach ('Q','K') {
	    if ($algebra{$_ . $wx} eq $rk) {
	      push @to,$sq  ;
	    }
	  }
	} else {
	  foreach ('Q','K') {
	    if ($algebra{$_ } eq $rk) {
	      push @to,$sq  ;
	    }
	  }
	}
      }
    }
    return ;
  }

  # ambiguités persistantes
  print "****   ambiguity   *** \n" ;
  return ;
}

sub resolve_deb {

  my ($color,$wpiece,$waction, $wdestalpha, $wdestnum ,$wechec)=@_ ;
  my $truepiece ;
  my $side ;
  my $piece ;
  my $col ;
  my $rank ;
  my $wcol ;
  my $loc ;
  my $case ;
  #ambiguité sur colonne

  if ($wpiece =~ /^([QRBKN])\/([1-8])$/) {
    # $truepiece=$1 ;
    ($wcol,$truepiece)=$color eq 'White' ? ($2,$1): ($black[$2],lc($1)) ;
    foreach $case (keys %{$bd}) {
      ($rank, $col)=split(//,$case) ;
      if ( ($bd->{$case} eq $truepiece)  && ($col == $wcol)  ) {
	push @from,$case ;
      }
    }
    return ($truepiece) ;
  }

  #ambiguité sur queen side  & king side
  #  ex  N=e4  et N =g8 => QN=e4 et KN=g8  e<g
  # pb avec 3 pieces ??

  if ($wpiece =~ /(^[QK])([QRBN]$)/ ) {
    $truepiece=$color eq 'White' ? $2:lc($2) ;
    $side=$1 ;
    my $i=0 ;
    my @loc ;

    foreach $case (keys %{$bd} ) {
      if ($bd->{$case} eq $truepiece ) {
	$loc[$i]= $case ;$i++ ;
      }
    }

    if ($#loc < 2) {
      push @from,( $side eq 'Q' ? ( ( substr($loc[0],0,1) lt substr($loc[1],0,1)) ? $loc[0]: $loc[1] )
		   : ( ( substr($loc[0],0,1) gt substr($loc[1],0,1)) ? $loc[0]: $loc[1] )) ;}
    else {
      print " ambiguity :  piece number gt  à 2 : $#loc \n  " ;
    }
  }

  return ($truepiece) ; 

  # ambiguités peristantes = not solved

  print "ambiguity at start of the mpve \n" ;

  return ; 
}



sub promote{
#check if the pawn get the last rank
# usage (piece chosen , = piece chosen)=promote(pawn,row location,piece chosen)
# dual syntax for the chosen piece X: =X or (X)  
my $tpiece=shift ;
  my $row=shift ;
  my $wechec=shift ;

  if( $tpiece eq 'P' && $row==8){
# retrieve the piece to promote
$wechec=~ s/[\(|=]\s*([QNBR])\s*\)?/$1/ ;
return ($wechec,'='. uc($wechec) ) ;}

  if( $tpiece eq 'p' && $row==1){
# retrieve the piece to promote
$wechec=~ s/[\(|=]\s*([QNBR])\s*\)?/$1/ ;
return (lc $wechec,'='. uc($wechec) ) ;}
# not a pawn to promote , nothing to do
return ($tpiece,"") ;
}
}
1 ;
