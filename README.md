# ChessLogic

Functional Chess validator written in Elixir. Depends on Erlang [fcardinaux/chessfold](https://github.com/fcardinaux/chessfold/blob/master/erl/chessfold.erl).

It uses leex to parse pgn files, and chessfold to implement chess logic. Both in Erlang.

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

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `chess_logic` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chess_logic, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/chess_logic](https://hexdocs.pm/chess_logic).

## Sample usage

More sample usage in the test folder.

 ```elixir
iex(1)> g = ChessLogic.Game.new
%ChessLogic.Game{
  current_position: %ChessLogic.Position{
    fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
    position: [
      ["r", "n", "b", "q", "k", "b", "n", "r"],
      ["p", "p", "p", "p", "p", "p", "p", "p"],
      [" ", " ", " ", " ", " ", " ", " ", " "],
      [" ", " ", " ", " ", " ", " ", " ", " "],
      [" ", " ", " ", " ", " ", " ", " ", " "],
      [" ", " ", " ", " ", " ", " ", " ", " "],
      ["P", "P", "P", "P", "P", "P", "P", "P"],
      ["R", "N", "B", "Q", "K", "B", "N", "R"]
    ]
  },
  history: [],
  result: nil,
  status: :started,
  winner: nil
}
iex(2)> {:ok, g} = ChessLogic.Game.play(g, "e2e4")
{:ok,
 %ChessLogic.Game{
   current_position: %ChessLogic.Position{
     fen: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
     position: [
       ["r", "n", "b", "q", "k", "b", "n", "r"],
       ["p", "p", "p", "p", "p", "p", "p", "p"],
       [" ", " ", " ", " ", " ", " ", " ", " "],
       [" ", " ", " ", " ", " ", " ", " ", " "], 
       [" ", " ", " ", " ", "P", " ", " ", " "],
       [" ", " ", " ", " ", " ", " ", " ", " "],
       ["P", "P", "P", "P", " ", "P", "P", "P"],
       ["R", "N", "B", "Q", "K", "B", "N", "R"]
     ]
   },
   history: [
     %{
       fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
       move: "e2e4",
       san: "e4"
     }
   ],
   result: nil,
   status: :playing,
   winner: nil
 }}
iex(3)> {:ok, g} = ChessLogic.Game.play(g, "g8f6")
{:ok,
 %ChessLogic.Game{
   current_position: %ChessLogic.Position{
     fen: "rnbqkb1r/pppppppp/5n2/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 1 2",
     position: [
       ["r", "n", "b", "q", "k", "b", " ", "r"],
       ["p", "p", "p", "p", "p", "p", "p", "p"],
       [" ", " ", " ", " ", " ", "n", " ", " "],
       [" ", " ", " ", " ", " ", " ", " ", " "],
       [" ", " ", " ", " ", "P", " ", " ", " "],
       [" ", " ", " ", " ", " ", " ", " ", " "],
       ["P", "P", "P", "P", " ", "P", "P", "P"],
       ["R", "N", "B", "Q", "K", "B", "N", "R"]
     ]
   },
   history: [
     %{
       fen: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
       move: "g8f6",
       san: "Nf6"
     },
     %{
       fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
       move: "e2e4",
       san: "e4"
     }
   ],
   result: nil,
   status: :playing,
   winner: nil
 }}
```