defmodule ChessLogic do
  @moduledoc """
  Documentation for ChessLogic API.

  It mostly delegates to Game

  * To play a game...

  iex> g = ChessLogic.new_game
  iex> {:ok, g} = ChessLogic.play(g, "e4")
  iex> {:ok, g} = ChessLogic.play(g, "e5")

  * To print a game
  iex> ChessLogic.print_game g
  ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
  ♟ ♟ ♟ ♟   ♟ ♟ ♟

          ♟
          ♙

  ♙ ♙ ♙ ♙   ♙ ♙ ♙
  ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖

  * Import/Export PGN

  To test Import from PGN, You can use test/fixtures files, for example, games from Grenke 2018.
  (It takes some time to load games, as it not optimized)

  iex> games = ChessLogic.from_pgn_file "./test/fixtures/GRENKEChessClassic2018.pgn"

  To export...
  iex> games |> Enum.map(fn game -> ChessLogic.to_pgn(game) end)

  FILES NEEDS TO BE UTF8! If it is not, You can add iconv for conversion.
  """

  alias ChessLogic.Game
  # alias ChessLogic.{Game, Position}

  # Game
  defdelegate new_game(), to: Game, as: :new
  defdelegate new_game(fen), to: Game, as: :new
  defdelegate play(game, move), to: Game
  defdelegate draw(game), to: Game
  defdelegate resign(game), to: Game
  defdelegate set_result(game, result), to: Game
  #
  defdelegate to_pgn(game), to: Game
  defdelegate from_pgn(pgn), to: Game
  defdelegate from_pgn_file(file), to: Game
  defdelegate print_game(game), to: Game, as: :print

  # Position
  # defdelegate from_fen(fen), to: Position
  # defdelegate to_fen(position), to: Position
  # defdelegate position_status(position), to: Position, as: :status
  # defdelegate all_possible_moves(position_or_fen), to: Position
  # defdelegate all_possible_moves_from(position, piece_or_square), to: Position
  # defdelegate is_king_attacked(position_or_fen), to: Position
  # defdelegate play_position(position, move), to: Position, as: :play
  # defdelegate print_position(position), to: Position, as: :print
end
