Definitions.

TAG            = \[[^\]]*\]
% Move number
MOVE           = [1-9][0-9]*\.(\.)?(\.)?
% Short Algebric Notation
SAN  = ([BKNPQR])?(([a-h])?([1-8])?)(x)?([a-h])([1-8])(\s*[eE]\.?[pP]\.?\s*)?(=([BNQR]))?([\+#])?
VARIATION      = \(.*\)
COMMENT_INLINE = {.*}
COMMENT_EOL    = ;.*
MOVE_EVAL      = (!|!!|\?|\?\?|!\?|\?!)?
POS_EVAL       = (=)?(\+=)?(=\+)?(\+\/=)?(=\/\+)?(\+\/-)?(-\+)?(\+\/-)?(-\/\+)?
CASTLING       = O-O(-O)?
RESULT         = 1-0|0-1|1\/2-1\/2|\*
WHITESPACE     = [\s\t\n\r]

Rules.

{TAG}            : {token, {tag, TokenLine, TokenChars}}.
{MOVE}           : {token, {move, TokenLine, TokenChars}}.
{SAN}            : {token, {san, TokenLine, TokenChars}}.
{VARIATION}      : {token, {variation, TokenLine, TokenChars}}.
{COMMENT_INLINE} : {token, {comment, TokenLine, TokenChars}}.
{COMMENT_EOL}    : {token, {comment, TokenLine, TokenChars}}.
{MOVE_EVAL}      : {token, {move_eval, TokenLine, TokenChars}}.
{POS_EVAL}       : {token, {pos_eval, TokenLine, TokenChars}}.
{CASTLING}       : {token, {castling, TokenLine, TokenChars}}.
{RESULT}         : {token, {result, TokenLine, TokenChars}}.
{WHITESPACE}+    : skip_token.

Erlang code.
