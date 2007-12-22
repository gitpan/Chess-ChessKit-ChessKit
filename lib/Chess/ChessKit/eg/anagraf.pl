#!/usr/bin/perl -w
####-----------------------------------
### File	: anagraf.pl
### Author	: C.Minc
### Purpose	: Count valid moves and checks GUI results
### Version	: 2.0 2007/01/22
### copyright GNU license
####-----------------------------------



use strict;
use warnings;

use Chess::PGN::Parse 0.18 ;
use Chess::ChessKit::Board  ;


our $VERSION = '2.0';

use strict;
use Tk;
require Tk::Dialog ;
require Tk::LabEntry;

my @aw_mv=() ;
my @ab_mv=() ;
my $w_mv=\@aw_mv ;
my $b_mv=\@ab_mv ;
my $diffmax=0 ;
my $diffmin=0 ;
&ana ;

=pod

for (my $i=0 ; $i<=$#ab_mv ; $i++){
my $diff=$aw_mv[$i]  - $ab_mv[$i] ;
print "$i  -- $aw_mv[$i]  -- $ab_mv[$i]  diff=$diff  \n" ;}
if($#aw_mv > $#ab_mv) {print "$#aw_mv  -- $aw_mv[$#aw_mv]  \n" ;}

=cut

my $DIALOG_ABOUT ;
my $MBF ;
my $DIALOG_USAGE ;
my $CANV ;
my $MAX_PXL=500 ;
my $MARGIN=90 ;
my $MIN_PXL=50 ;

my $X_MIN=1 ;  # plot parameters
my $X_MAX= $#ab_mv ; # plot parameters
my $Y_MAX=$diffmax ;  # plot parameters
my $Y_MIN=$diffmin ;  # plot parameters

my $label_offset=50 ;
my $tick_length=10 ;

my $TEXT ;
my @COLORS=('black','red','green','yellow','blue','magenta') ;
my $NUM_COLORS=6 ;
my $canv_x ;
my $canv_y ;

my $ALEN=$MAX_PXL-$MIN_PXL-2*$MARGIN ;

my $x ;
my $y ;

my $DX ;
my $DY ;

# my @FUNCTIONS=('cos($x)','sin($x)','$x') ;
#my @FUNCTIONS=('$x','1','-1','0','int($x)','&bid($x)','-$x/2.0') ;
#my @FUNCTIONS=('$x','1','1.01','1.02','1.03','1.04','1.05','1.06') ;
#my @FUNCTIONS=('0','&dbsonl($x)','&dbsonr($x)') ;
#my @FUNCTIONS=('0','sonl($x)') ;
#my @FUNCTIONS=('&wtmn($x)','&btmn($x)') ;
my @FUNCTIONS=('0','&wtbtmn($x)') ;

my $MW = MainWindow->new; 

$DIALOG_ABOUT = $MW->Dialog(
    -title   => 'About',
    -text    => "plot_program $VERSION\n\n 2007/01/22",
    -bitmap  => 'info',
    -buttons => ['Dismiss']);

$MBF = $MW->Frame(-relief => 'raised', -borderwidth => 1);
$MBF->pack(-fill => 'x'); 
&make_menubutton($MBF, 'File', 0, 'left', [ ['Quit', \&exit, 0]]);
&make_menubutton($MBF, 'Help', 0, 'right', [
    ['About', [$DIALOG_ABOUT => 'Show'], 0],
    ['',      undef,                     0],
    ['Usage', [$DIALOG_USAGE => 'Show'], 0]]);

sub make_menubutton {
my ($param1,$param2,$shortcut,$side,$param)=@_ ;

# for debug
#my $max=$#{$param}  ;
#foreach (0..$max) {
#print $param->[$_][0] , " make  $_\n" ;}

my $b_menu=$param1->Menubutton(-text => $param2,
                 -underline => $shortcut) -> pack(-side,$side)  ;

foreach (0..$#{$param}) {
$b_menu->AddItems(
                [ "command", $param->[$_][0],
                -command => $param->[$_][1] ,
                -underline => $param->[$_][2] ]) ;
}

return ;
}


$CANV = $MW->Canvas(
    -width  => $MAX_PXL + $MARGIN * 2,
    -height => $MAX_PXL  ,
    -relief => 'sunken');
$CANV->pack; 
$CANV->CanvasBind('<Button-1>' => \&display_coordinates);

$CANV->createText( 325, 25,
    -text => 'Plot  Functions Of The Form y=f($x)',
    -fill => 'blue');

# Create the line to represent the X axis and label it. Then label the 
# minimum and maximum X values and draw tick marks to indicate where they 
# fall. The axis limits are LabEntry widgets embedded in Canvas windows.

# axe des X

$CANV->createLine( 
		  $MIN_PXL + $MARGIN, $MAX_PXL - $MARGIN,
		  $MAX_PXL - $MARGIN, $MAX_PXL - $MARGIN);

$CANV->createWindow( 
		    $MIN_PXL + $MARGIN, $MAX_PXL - $label_offset,
		    -window => $MW->LabEntry( 
					     -textvariable => \$X_MIN,
					     -label        => 'X Minimum'));

$CANV->createLine( 
		  $MIN_PXL + $MARGIN, $MAX_PXL - $MARGIN - $tick_length,
		  $MIN_PXL + $MARGIN, $MAX_PXL - $MARGIN + $tick_length);

$CANV->createWindow( 
		    $MAX_PXL - $MARGIN, $MAX_PXL - $label_offset,
		    -window => $MW->LabEntry(
					     -textvariable => \$X_MAX,
					     -label        => 'X Maximum'));

$CANV->createLine(
		  $MAX_PXL - $MARGIN, $MAX_PXL - $MARGIN - $tick_length,
		  $MAX_PXL - $MARGIN, $MAX_PXL - $MARGIN + $tick_length);

# axe des Y

$CANV->createLine( 
		  $MAX_PXL - $MARGIN, $MIN_PXL + $MARGIN,
		  $MAX_PXL - $MARGIN, $MAX_PXL - $MARGIN);

$CANV->createWindow(
		    #
		    $MAX_PXL ,$MAX_PXL - $MARGIN,
		    -window => $MW->LabEntry( 
					     -textvariable => \$Y_MIN,
					     -label        => 'Y Minimum'));

$CANV->createLine( 
		  $MAX_PXL - $MARGIN - $tick_length, $MIN_PXL + $MARGIN,
		  $MAX_PXL - $MARGIN + $tick_length, $MIN_PXL + $MARGIN);

$CANV->createWindow( 
		    #    $MAX_PXL - $MARGIN, $MAX_PXL - $label_offset,
		    $MAX_PXL, $MIN_PXL + $MARGIN,

		    -window => $MW->LabEntry(
					     -textvariable => \$Y_MAX,
					     -label        => 'Y Maximum'));

$CANV->createLine(
		  $MAX_PXL - $MARGIN - $tick_length, $MAX_PXL - $MARGIN,
		  $MAX_PXL - $MARGIN - $tick_length,$MAX_PXL - $MARGIN);

$MW->Frame(-height => 20)->pack;
$MW->Label(
    -text       => 'Enter your functions here',
    -foreground => 'blue')->pack;


# Create a Frame with a scrollable Text widget that displays the function
# list, and a Button to initiate plot activities.

my $functions_frame = $MW->Frame;
$functions_frame->pack;
$TEXT = $functions_frame->Scrolled(qw/Text -height 6 -scrollbars e/ );
$TEXT->pack;

# update_functions;

my $buttons_frame = $MW->Frame;
$buttons_frame->pack(-padx => 10, -pady => 5, -expand => 1, -fill => 'x');
my @pack_attributes = qw/-side left -fill x -expand 1/;
$buttons_frame->Button(
    -text    => 'Plot',
    -command => \&plot_functions)->pack(@pack_attributes);

$TEXT->delete('0.0', 'end');
my $i = 0;
foreach (@FUNCTIONS) {
    $TEXT->insert('end', "$_\n", [$i]);
    $TEXT->tagConfigure($i,
        -foreground => $COLORS[$i % $NUM_COLORS],
        -font => '9x15');
    $i++;
}
$TEXT->yview('end');

sub plot_functions {
my $dot='.' ;
#my $dot='*' ;
#my $dot='+' ;
$CANV->delete('plot');
$canv_x  =$MIN_PXL  + $MARGIN;  # X minimun
$DX = $X_MAX - $X_MIN;          # update delta X
$DY = $Y_MAX - $Y_MIN;          # update delta Y
my $cor=-4 ;                    # correction offset y ? 

 foreach (0 .. $#FUNCTIONS) {

ALL_X_VALUES:
#for ($x = $X_MIN; $x <= $X_MAX; $x += ($X_MAX - $X_MIN) / $ALEN) {
for (my $i=0; $i <= $ALEN ; $i++) {
$x=$i*$DX/$ALEN+$X_MIN ;


    ALL_FUNCTIONS:
        $y = eval $FUNCTIONS[$_]; 
        $canv_x  =(($x- $X_MIN)*$ALEN)/$DX + $MARGIN + $MIN_PXL ;
        $canv_y = (($Y_MIN-$y)*$ALEN)/$DY -  $MARGIN +$MAX_PXL;
        $CANV->createText($canv_x, $canv_y + $cor,
          -fill => $COLORS[$_ % $NUM_COLORS],
          -tags => ['plot'],
          -text => $dot) if( $canv_y >= ( $MIN_PXL + $MARGIN) and $canv_y <= ($MAX_PXL - $MARGIN) );
    } # forend ALL_FUNCTIONS
 #   $canv_x++; # next X pixel

} # forend ALL_X_VALUES

return ;
}
MainLoop ;


sub display_coordinates {
    my($canvas) = @_;
    my $e = $canvas->XEvent;
    my($canv_x, $canv_y) = ($e->x, $e->y);
    my($x, $y);
    $x = $X_MIN + $DX * (($canv_x - $MARGIN-$MIN_PXL) / $ALEN);
    $y = $Y_MIN - $DY * (($canv_y -$MAX_PXL+ $MARGIN) / $ALEN);
#    print "\n Canvas x = $canv_x, Canvas y = $canv_y.\n";
    print "Plot x = $x, Plot y = $y.\n";
} # end display_coordinates

sub bid {
my $x=shift ;
sin($x*$x) ;
}

sub btmn{
my $x=shift ;
my $e=int($x) ;
return $b_mv->[$e] ;
}

sub wtmn{
my $x=shift ;
my $e=int($x) ;
return $w_mv->[$e] ;
}

sub wtbtmn{
my $x=shift ;
my $e=int($x) ;
return $w_mv->[$e]- $b_mv->[$e] ;
}

sub ana {

#!/usr/bin/perl -w
####-----------------------------------
### File	: analizmov.pl
### Author	: C.Minc
### Purpose	: Count valid moves and checks
### Version	: 1.1 20/8/2005
### copyright GNU license
####-----------------------------------



use strict;
use warnings;

use Chess::PGN::Parse 0.18 ;
use Chess::ChessKit::Board  ;

use Tk::FileSelect;

our $VERSION = '1.1';

# global local vars
my $ref ;
my $currMove = 1 ; 
my $piece ;
my $from ;
my $take ;
my $dest ;
my $check ;
my @start ;
my $status={} ;

my $main = MainWindow->new(-title => "selection de la partie");
my $fs=$main->FileSelect(-directory => '.') ;
$fs->configure( -width => "50" );
my  $file=$fs->Show ;

print " analyse la partie : $file \n" ;

# create the chessboard at the beginning position

my $bd=Board->new() ;
$bd->startgame() ;
$bd->has_moved(status=>$status,ini=>'y') ;

# show the initial status 
#foreach (keys %{$status}){ print "$_  $status->{$_} " ;}
#print "\n" ;

# read the pgn file and split each moves

my $game = Chess::PGN::Parse->new($file);
$game->read_game();
# modif perl 5.8.8
#my @moves = @{$game->smart_parse_game()};
$game->smart_parse_game() ;
my @moves=@{$game->moves()} ; # correction due to perl  5.8.8

#  analyse the position and calculates the number of moves
# avalaible for whites and blacks


$w_mv->[0]=20 ;
foreach (@moves) {

#$bd->chessview ;
#$bd->bestmove ;

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
# FOR DEBUG
#print "$currMove  $_  blancs=$nw moves noirs=$nb moves \n " ;

my $TrueMove=int($currMove / 2) ;
if(int($currMove % 2) == 1 ) {$w_mv->[$TrueMove]=$nw ;}
else {$b_mv->[$TrueMove-1]=$nb ;}

# you can verify if kings are checked by uncommented the following
#$bd->is_shaked(king=>'k',out=>'y') ;
#$bd->is_shaked(king=>'K',out=>'y') ;

# the status must be updated  after every moves to be valid
$bd->has_moved(status=>$status) ;


  $currMove++;


}

# check the final position (but not the empty squares)
# $bd->chessview ;
print "\n\n Resultats \n\n" ;
for (my $i=0 ; $i<=$#ab_mv ; $i++) {
my $j=$i+1 ;
my $k=$i << 1 ;
my $diff=$aw_mv[$i]  - $ab_mv[$i] ;
$diffmax=$diffmax < $diff ? $diff : $diffmax ;
$diffmin=$diffmin < $diff ? $diffmin : $diff ;

print "$j\.$moves[$k]\t\($aw_mv[$i]\)\t$moves[$k+1]\t\($ab_mv[$i]\)\tdiff=$diff  \n" ;}

if($#aw_mv > $#ab_mv) {
my $i=$#aw_mv ;
my $j=$i+1 ;
my $k=$i << 1 ;
print "$j\.$moves[$k]\t\($aw_mv[$i]\) \n" ;}

# moves start at 1, so shift the array
unshift(@aw_mv,20) ;
unshift(@ab_mv,20) ;

return ;
}
