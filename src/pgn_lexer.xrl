% https://searchcode.com/file/74463574/pgn.go

Definitions.

TAG            = \[[^\]]*\]
% Move number.
MOVE           = [1-9][0-9]*\.(\.)?(\.)?
% Short Algebric Notation.
SAN  = ([BKNPQR])?(([a-h])?([1-8])?)(x)?([a-h])([1-8])(\s*[eE]\.?[pP]\.?\s*)?(=([BNQR]))?([\+#])?
VARIATION      = \(.*\)
% Comments wrapped in {} can be multilined.
COMMENT        = {[^}]*}
% Comments EOL starts with ; until the end of line.
COMMENT_EOL    = ;.*
MOVE_EVAL      = (!|!!|\?|\?\?|!\?|\?!)?
POS_EVAL       = (=)?(\+=)?(=\+)?(\+\/=)?(=\/\+)?(\+\/-)?(-\+)?(\+\/-)?(-\/\+)?
NAG            = \$[0-9]*
CASTLING       = O-O(-O)?
RESULT         = 1-0|0-1|1\/2-1\/2|\*
WHITESPACE     = [\s\t\n\r]

Rules.

{TAG}            : {token, {tag, TokenLine, TokenChars}}.
{MOVE}           : {token, {move, TokenLine, TokenChars}}.
{SAN}            : {token, {san, TokenLine, TokenChars}}.
{VARIATION}      : {token, {variation, TokenLine, TokenChars}}.
% Both comments
{COMMENT}        : {token, {comment, TokenLine, TokenChars}}.
{COMMENT_EOL}    : {token, {comment, TokenLine, TokenChars}}.
{MOVE_EVAL}      : {token, {move_eval, TokenLine, TokenChars}}.
{POS_EVAL}       : {token, {pos_eval, TokenLine, TokenChars}}.
{NAG}            : {token, {nag, TokenLine, TokenChars}}.
% Castling is also a san
{CASTLING}       : {token, {san, TokenLine, TokenChars}}.
{RESULT}         : {token, {result, TokenLine, TokenChars}}.
{WHITESPACE}+    : skip_token.

Erlang code.
