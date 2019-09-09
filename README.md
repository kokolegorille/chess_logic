# ChessLogic

## Description

This package contains logic to play the game of chess. 
Functional Chess validator written in Elixir. 

It uses leex and yecc to parse pgn files.

It understands following rules:

* draw by 3 times the same position
* draw by 50 moves rule
* mat
* pat
* check
* taken
* en passant
* castling

But it does not understand draw by not enough material rule! It is not meant to be an AI of some sort, just a simple chess move validator (and generator), to be used in a larger project.

It also supports importing/exporting pgn files.

## Installation

The package can be installed by adding `chess_logic` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:chess_logic, "~> 0.3.0"}]
end
```

## Changelog 

Version 0.3.0 is a complete rewrite, the code is now only in Elixir, except the lexer and parser, which are in Erlang and used for pgn import.

Because of the rewrite, code organization is different from previous version, but API is (almost) the same and tests are passing.

It supports short algebric notation (SAN), so it's possible to play e4, instead of e2e4, or Nf3 instead of g1f3. It's also possible to use long notation, as previously.

The print game version support Unicode.

TODO: Fix credo warnings about code complexity.

Version 0.2.0 and 0.2.1 broken! mix did not include src folder! Update to version 0.2.2!

[Available in Hex](https://hex.pm/packages/chess_logic).

Documentation can be found at [https://hexdocs.pm/chess_logic](https://hexdocs.pm/chess_logic).

## Erlang and dialyxir configuration

Because of some warnings detected in Erlang outside code (leex), it is nice to configure dialyxir to avoid them... 

Update mix.exs

      erlc_paths: ["src"],
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings"
      ],

Add file ./dialyzer.ignore-warnings

```elixir
Function yyrev/2 will never be called
```

## Sample usage

More sample usage in the test folder.

 ```elixir
iex(1)> g = ChessLogic.new_game
iex(2)> {:ok, g} = ChessLogic.play(g, "e4")
iex(3)> {:ok, g} = ChessLogic.play(g, "Nf6")
iex(4)> ChessLogic.print_game g             
♜ ♞ ♝ ♛ ♚ ♝   ♜
♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟
          ♞    
               
        ♙      
               
♙ ♙ ♙ ♙   ♙ ♙ ♙
♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖
:ok
iex(5)> g |> ChessLogic.to_pgn()
"1. e4 Nf6"
```