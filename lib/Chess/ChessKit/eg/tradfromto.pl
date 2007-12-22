 #!/usr/bin/perl -w
 ####-----------------------------------
 ### File	: tradfromto.pl
 ### Author	: C.Minc
 ### Purpose	: chess translator - user graphic interface
 ### Version	: 1.1 2007/12/22
 ### copyright GNU license
 ####-----------------------------------

 our $VERSION = '1.1';

 use strict;
 use English ;
 use Tk;
 use Tk::LabEntry;
 use Tk::LabFrame;
 require Tk::Dialog ;
 use Chess::ChessKit::Trad ;

 # here are the tables we needed if you wish to add a new country in Trad.pm
 #Language     Piece letters (pawn knight bishop rook queen king)
 #----------   --------------------------------------------------
 #Czech        P J S V D K
 #Danish       B S L T D K
 #Dutch        O P L T D K
 #English      P N B R Q K
 #Estonian     P R O V L K
 #Finnish      P R L T D K
 #French       P C F T D R
 #German       B S L T D K
 #Hungarian    G H F B V K
 #Icelandic    P R B H D K
 #Italian      P C A T D R
 #Norwegian    B S L T D K
 #Polish       P S G W H K
 #Portuguese   P C B T D R
 #Romanian     P C N T D R
 #Spanish      P C A T D R
 #Swedish      B S L T D K

 #my %country=(
 #Czech       =>'Czech     ',
 #Danish      =>'Danish    ',
 #Dutch       =>'Dutch     ',
 #English     =>'English   ',
 #Estonian    =>'Estonian  ',
 #Finnish     =>'Finnish   ',
 #French      =>'French    ',
 #German      =>'German    ',
 #Hungarian   =>'Hungarian ',
 #Icelandic   =>'Icelandic ',
 #Italian     =>'Italian   ',
 #Norwegian   =>'Norwegian ',
 #Polish      =>'Polish    ',
 #Portuguese  =>'Portuguese',
 #Romanian    =>'Romanian  ',
 #Spanish     =>'Spanish   ',
 #Swedish     =>'Swedish   ') ;


 my %bb ;
 my %bb2 ;
 my $lang ;
 my $lang2 ;
 my $file ="./inputgame.pgn" ;
 my $fileresult= "./translated.pgn" ;

 my $top = MainWindow->new(-title=>" translate from left to right selected buttons");
 my $frame1=$top->Frame ;
 my $frame2=$top->Frame ;
 $frame1->pack(-side=>"left") ;
 $frame2->pack(-side=>"left") ;

 foreach (sort(keys %Trad::country) ) {
   $bb{$_} = $frame1->Radiobutton(-text => $Trad::country{$_},
				  -value => $_,
				  -variable => \$lang)->pack(-side => 'top',-anchor=>'w');
   $bb2{$_} = $frame2->Radiobutton(-text => $Trad::country{$_},
				   -value => $_,
				   -variable => \$lang2)->pack(-side => 'top',-anchor=>'w');
 }
 $bb{French}->select ;

 $bb2{English}->select ;
 my $fl = $top->LabFrame(-label => "File Selection", -labelside => "top");
 $fl->LabEntry(-label => "input file",-width=>"80", -textvariable => \$file)->pack;
 $fl->LabEntry(-label => "output file",-width=>"80", -textvariable => \$fileresult)->pack;
 $fl->pack;
 my $b1 = $top->Button(
		       -text => "Continue",
		       -command => sub {&Trad::trad($fileresult,$file,$lang,$lang2) ;
					$top->destroy;})->pack(-side=>'bottom',-anchor=>'s',-fill=>'x') ;
 $b1->configure( -background =>'green',
		 -activebackground => 'yellow') ;
 MainLoop ;


 print "\n\t\tfin du programme $0\n" ;


