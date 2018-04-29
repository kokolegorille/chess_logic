%%%%%%%%%%%%%%%%%%%%
%% Non terminals
%%%%%%%%%%%%%%%%%%%%

Nonterminals
trees tree tags elems elem variation.

%%%%%%%%%%%%%%%%%%%%
%% Terminals
%%%%%%%%%%%%%%%%%%%%

Terminals
tag move san comment move_eval pos_eval nag result '(' ')'.

%%%%%%%%%%%%%%%%%%%%
%% Rootsymbol
%%%%%%%%%%%%%%%%%%%%

Rootsymbol trees.

%%%%%%%%%%%%%%%%%%%%
%% Rules
%%%%%%%%%%%%%%%%%%%%

trees -> tree : ['$1'].
trees -> tree trees : ['$1'] ++ '$2'.

tree -> tags elems : {tree, '$1', '$2'}.

tags -> tag : ['$1'].
tags -> tag tags : ['$1'] ++ '$2'.

variation -> '(' elems ')' : {variation, '$2'}.
variation -> '(' elems variation ')' : {variation, '$2', '$3'}.

elems -> variation : ['$1'].
elems -> variation elems : ['$1'] ++ '$2'.

elems -> elem : ['$1'].
elems -> elem elems : ['$1'] ++ '$2'.

elem -> san : '$1'.
elem -> move : '$1'.
elem -> comment : '$1'.
elem -> move_eval : '$1'.
elem -> pos_eval : '$1'.
elem -> nag : '$1'.
elem -> result : '$1'.

%%%%%%%%%%%%%%%%%%%%
%% Erlang code
%%%%%%%%%%%%%%%%%%%%

Erlang code.

% unwrap({_,_,V}) -> V.
