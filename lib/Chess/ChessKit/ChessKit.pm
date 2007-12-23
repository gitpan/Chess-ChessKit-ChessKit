

package Chess::ChessKit;


=head1 NAME

Chess::ChessKit  A set of program to translate chess notations and analyses game by moves count
                 

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

=head1 SYNOPSIS

ChessKit is composed of:

=over

=item

Move.pm : basic moves on an empty board.

=item

Board.pm: functions for valid moves in a true game.

=item

Trad::trad : functions to translate algebraic from one language 
             to another one

=item

Trad::dscrip :Translate english descriptive notation to 
              long english algebraic

=item

tradfromto.pl: standalone with a GUI (Tk/perl) using Trad::trad.

=item

dscripdata.pl: example using Trad::dscrip and checks distribution

=item

anagraf.pl: example using Chess::ChessKit:Board to find "best" moves 
              according to TMN with GUI
	      
=item

analizmov.pl: example using Chess::ChessKit:Board to find "best" moves 
              according to TMN

=back

note: TMN : Theoretical move number : it's the precise number of different 
valid moves at the disposal of the chess player having to play.

=head1 DESCRIPTION

ChessKit is a set of programs and packages 
to translate any chess notation into
another one.
As a consequence we have to provide software
that can validate pieces (or pawns) moves.

About chess theory somebody states that advantage
belongs to the player who has the bigger number
of moves. So, to help to verify and pursue the idea,routines for that purpose 
have been developped.

=head1 EXPORT

all the functions below here.


=head1 FUNCTIONS inside Chess::ChessKit::Board



B<$gmv{$piece}(row=>>$somerow,
B<             col =>>$somecolumn,
B<             mov=>>$ref_array_of_mov,
B<             color=>>$piece) ;

return in $ref_array_of_mov all the moves that $piece written like
in FEN (for example 'N' for White Knight, 'n' for Black Knight and so on).
($somerow,$somecolumn) are the coordinates of the starting square.
color is again $piece because all the Whites are in upper case and blacks
in lower case.


B<$bd->>B<bestmove> ; print a list of the best moves in the sense of TMN

B<$bd->>B<boardcopy($new_board)> ; 
copy the position of board $bd to the other board $new_board

B<$diag=$bd->>B<can_castling(roq=>>$roq  ,
B<                     status=>>$ref_status, 
B<                     out=>>$out) ;
check if a king can castle according to $ref_status (updated by 
has_moved). Also, verify the king is not checked.
$roq=(KK|QK|kk|qk) where the first letter design the side and
the second the king color. 
$out=('yes'|'no')
if $out is to 'yes' a message indicates which pieces
give a check. Default is 'no'. 
This function return 'yes' or 'no'.

B<$bd->>B<cantake(who=>>$piece,
B<             where=>>$some_square) ;
return 'no' if not possible or the type of the piece that can be taken.

B<$bd->>B<castling(couleur=>>$couleur,
B<                side=>>$side,
B<                status=>>$ref_status,
B<                out=>>$out) 
execute castling if can_castling return 'yes' or die with diagnostic.
Parameters can take the following values:

=over

=item
$couleur=('White|'Black')

=item
$side(K|Q)

=item
$ref_status is the parameter already described above.

=item
$out=('yes'|'no')
transmit this data to can_castling which print which piece
give a check. Default is 'no'.

=back

B<my ($cnt_white,$cnt_black)=$bd->>B<chessmovcnt>
scan the board and return the count of the valid moves for both
Blacks and Whites. (used next program-maintain for backward
compatibility

B<my %sum=$bd->>B<chessmovcntint>
scan the board and return the set of squares of the valid moves for 
Blacks @{$sum{b}} and Whites  @{$sum{w}}.
We can retrieve the datas as before for the above routine 
by the following way:

	$cnt_white=@{$sum{w}} ;
	$cnt_black=@{$sum{b}} ;

Note: squares could be duplicated in the hash

B<$bd->>B<chessview>
print the board on screen.

B<$bd->>B<deletepiece($location)>
delete the piece at location $location that are 
the algebraic coordinate of a square.

B<$piece=$bd->>B<getpiece($location)>
retrieve the type of piece at board location $location

B<has_moved(status=>>$ref_status,
B<             ini=>>$ini)>
set the status of Rook and king to know if they are
always at there original place. So this function 
must be called after every moves.
$ini=('y'|'no') if this parameter is set to 'y' the status is reset.
The default option is of course 'no'.

B<bd->>B<is_shaked(king=>>$king,
B<                 out=>>$out)
Diagnose if a king is checked by returning 'yes' or "" 
$out conditional parameter for printing the result if equal 'y'

B<$bd=Board->>B<new();>
create the objet $bd of class Board.

B<$bd->>B<print>
print the position of pieces: location and type

B<$bd->>B<put($piece,$location)>
place a piece $piece on the chessboard at $location

B<$bd->>B<startgame(%set_position)>
initialize the chessboard with %set_position. Default without argument
is the usual chessboard starting game.


B<$bd->>B<valid(mov=>>$set_of move,
B<              valid=>>$set,
B<              piece=>>$piece)
intermediate validation of moves. Use
datas obtained from %gmv : $set_of_move for $piece.
It returns $set , the moves restricted to the true board.


B<$bd->>B<vldmov(valid=>>$set,
B<               piece=>>$piece,
                 row=>>$row,
                 col=>>$col,
                 recur=>>$control)
Final validation of moves, where
all the rules of chessgame are taken under consideration.
Castling is separated and described before.

B<$bd->>B<getfen($fen,$posini,$status)>
where $fen is the FEN string and $posini a hash reference
used to initialize the game by :

	$bd->startgame($posini)

$status is the status game as described before.

B<$bd->>B<genfen($colmove,$status,$ep,$ply,$nmove)>
genfen is the inverse function of getfen. It returns
the FEN string if we provides the classical chess data
of the colors who had to play $colmove ('w' or 'b'),
the status $status set by $bd->hasmoved($status),
 the column of the pawn if the taken "en passant"
is possible $ep,the ply count $ply and at last, 
the game move count $nmove.

=head1 FUNCTIONS inside Chess::ChessKit::Trad


B<trad($outfile,$infile,$lang ,$lang2translate)>
translate an algebraic file or pgn given by $infile to $outfile
where the source language is $lang and the output language is $lang2translate.
They can take the following values:
Czech|Danish|Dutch|English|Estonian|Finnish|French|German|Hungarian|
Icelandic|Italian|Norwegian|Polish|Portuguese|Romanian|Spanish|Swedish

B<@array_of_moves=dscrip(mov=>>$ref_array_of_moves ,
B<                       ini=>>$ref_hash_position)
Translate a descriptive notation with the following format:

=over

=item
  n. Whitemove BlackMove

=back

where n is the move number followed by a dot then by the
moves.(Note: last move of course could be only a white move)
The input is a reference to the array of the moves in decriptive notation,
An array in long algebraic notation is returned.
If a $ref_hash_position is given then the global variable $bd is 
set to those values. By default, it is again the initial chess game position. 


=head1 SEE ALSO

Chess::PGN,Chess::Board

=head1 AUTHOR

Charles Minc, C<< <charles.minc@wanadoo.fr> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-mymove@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Chess::ChessKit::ChessKit>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

L<http://www.chess-theory.com//enthnct03_1_new_chess_theory_unfolding_game.htm>

=head1 COPYRIGHT & LICENSE

Copyright 2005 Charles Minc, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Chess::ChessKit


