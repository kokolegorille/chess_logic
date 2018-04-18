%% @doc Chess Move Generator: Header file
%% @end
%% 
%% This file is released under the GNU General Public License (GPL) version 3.
%% 
%% @author François Cardinaux, CH 1207 Genève
%% @copyright 2011 François Cardinaux

% Noticeable values in 0x88 representation: 
-define(ROW_SPAN,             16).
-define(MOVE_UP,              16).
-define(MOVE_UP_LEFT,         15).
-define(MOVE_UP_RIGHT,        17).
-define(MOVE_UP_2,            32).
-define(MOVE_DOWN,           -16).
-define(MOVE_DOWN_LEFT,      -17).
-define(MOVE_DOWN_RIGHT,     -15).
-define(MOVE_DOWN_2,         -32).
-define(BOTTOM_LEFT_CORNER,    0).
-define(BOTTOM_RIGHT_CORNER,   7).
-define(TOP_LEFT_CORNER,     112).
-define(TOP_RIGHT_CORNER,    119).
                 
-define(CASTLING_ALL,         15).
-define(CASTLING_WHITE_KING,   8).
-define(CASTLING_WHITE_QUEEN,  4).
-define(CASTLING_BLACK_KING,   2).
-define(CASTLING_BLACK_QUEEN,  1).

% Positions of the elements inside the chessfold_piece record
-define(PIECE_RECORD_COLOR,    2).
-define(PIECE_RECORD_TYPE,     3).
-define(PIECE_RECORD_SQUARE,   4).

-type chessfold_piece_color()   :: 'black' | 'white'.
-type chessfold_piece_type()    :: 'pawn' | 'knight' | 'bishop' | 'rook' | 'queen' | 'king'.
-type chessfold_square()        :: ?BOTTOM_LEFT_CORNER..?TOP_RIGHT_CORNER. % In 0x88 representation
-type chessfold_castling()      :: 'false' | 'queen' | 'king'.

-record(chessfold_piece, {
            color                               :: chessfold_piece_color(), 
            type                                :: chessfold_piece_type(), 
            square                  = false     :: 'false' | chessfold_square()}). 
            
-record(chessfold_position, {
            pieces                              :: [#chessfold_piece{}], 
            turn                                :: 'false' | chessfold_piece_color(), 
            allowedCastling         = 0         :: 0..?CASTLING_ALL, 
            enPassantSquare         = false     :: 'false' | chessfold_square(), 
            halfMoveClock           = 0         :: integer(), 
            moveNumber              = 0         :: integer()}).
            
-record(chessfold_move, {
            from                                :: #chessfold_piece{},  
            to                                  :: #chessfold_piece{},             % May be a different piece, in case of promotion
            newPosition                         :: #chessfold_position{}, 
            castling            = false         :: chessfold_castling(), 
            taken               = false         :: 'false' | #chessfold_piece{}}). % Not necessarily the same square as 'to' (en passant)
            
% Source: Programming Erlang, p 424
-define(debug(X, Y), (begin
                    Info = io_lib:format(X, Y),
                    io:format("~nDebug in module ~p, line ~p:~n~p~n", [?MODULE, ?LINE, Info])
                 end)).
                 

