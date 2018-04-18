defmodule ChessLogic do
  @moduledoc """
  Documentation for ChessLogic.
  """
  
  alias ChessLogic.Game
  
  def new_game(fen \\ nil), do: Game.new(fen)
  
  defdelegate play(game, move), to: Game
  defdelegate draw(game), to: Game
  defdelegate resign(game), to: Game
  defdelegate set_result(game, result), to: Game
  defdelegate from_pgn(pgn), to: Game
  defdelegate to_pgn(game), to: Game
end
