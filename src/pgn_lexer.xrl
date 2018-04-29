%%%%%%%%%%%%%%%%%%%%
%% Definitions
%%%%%%%%%%%%%%%%%%%%

Definitions.

TAG            = \[[^\]]*\]
MOVE           = [1-9][0-9]*\.(\.)?(\.)?

% There is an ambiguity on 26.Nxc8+- as the plus can be seen as check!
SAN            = ([BKNPQR])?(([a-h])?([1-8])?)(x)?([a-h])([1-8])(\s*[eE]\.?[pP]\.?\s*)?(=([BNQR]))?([\+#]-?)?
POS_EVAL       = (=)?(\+=)?(=\+)?(\+\/=)?(=\/\+)?(\+-)?(-\+)?(\+\/-)?(-\+)?(\+\/-)?(-\/\+)?(\x{00B1})?(\x{2213})?

COMMENT        = {[^}]*}
COMMENT_EOL    = ;.*
MOVE_EVAL      = (!|!!|\?|\?\?|!\?|\?!)?

NAG            = \$[0-9]*
CASTLING       = O-O(-O)?
RESULT         = 1-0|0-1|1\/2-1\/2|\*

WHITESPACE     = [\s\t]
TERMINATOR     = [\n\r]

%%%%%%%%%%%%%%%%%%%%
%% Rules
%%%%%%%%%%%%%%%%%%%%

Rules.

\(             : {token, {'(', TokenLine}}.
\)             : {token, {')', TokenLine}}.

{POS_EVAL}     : {token, {pos_eval, TokenLine, TokenChars}}.

{TAG}          : {token, {tag, TokenLine, TokenChars}}.
{MOVE}         : {token, {move, TokenLine, TokenChars}}.
{SAN}          : {token, {san, TokenLine, TokenChars}}.
{COMMENT}      : {token, {comment, TokenLine, TokenChars}}.
{COMMENT_EOL}  : {token, {comment, TokenLine, TokenChars}}.
{MOVE_EVAL}    : {token, {move_eval, TokenLine, TokenChars}}.

{NAG}          : {token, {nag, TokenLine, TokenChars}}.
{CASTLING}     : {token, {san, TokenLine, TokenChars}}.
{RESULT}       : {token, {result, TokenLine, TokenChars}}.

{WHITESPACE}+  : skip_token.
{TERMINATOR}+  : skip_token.

%%%%%%%%%%%%%%%%%%%%
%% Erlang code
%%%%%%%%%%%%%%%%%%%%

Erlang code.
