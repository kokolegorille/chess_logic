defmodule ChessLogic.Piece do
  @moduledoc """
  Documentation for ChessLogic.Piece.
  """

  alias __MODULE__

  defstruct(
    color: nil,
    type: nil,
    square: nil
  )

  def read_piece("K"), do: %Piece{color: :white, type: :king}
  def read_piece("Q"), do: %Piece{color: :white, type: :queen}
  def read_piece("R"), do: %Piece{color: :white, type: :rook}
  def read_piece("B"), do: %Piece{color: :white, type: :bishop}
  def read_piece("N"), do: %Piece{color: :white, type: :knight}
  def read_piece("P"), do: %Piece{color: :white, type: :pawn}
  def read_piece("k"), do: %Piece{color: :black, type: :king}
  def read_piece("q"), do: %Piece{color: :black, type: :queen}
  def read_piece("r"), do: %Piece{color: :black, type: :rook}
  def read_piece("b"), do: %Piece{color: :black, type: :bishop}
  def read_piece("n"), do: %Piece{color: :black, type: :knight}
  def read_piece("p"), do: %Piece{color: :black, type: :pawn}
  def read_piece(" "), do: :empty

  def show_piece(%Piece{color: :white, type: :king}), do: "K"
  def show_piece(%Piece{color: :white, type: :queen}), do: "Q"
  def show_piece(%Piece{color: :white, type: :rook}), do: "R"
  def show_piece(%Piece{color: :white, type: :bishop}), do: "B"
  def show_piece(%Piece{color: :white, type: :knight}), do: "N"
  def show_piece(%Piece{color: :white, type: :pawn}), do: "P"
  def show_piece(%Piece{color: :black, type: :king}), do: "k"
  def show_piece(%Piece{color: :black, type: :queen}), do: "q"
  def show_piece(%Piece{color: :black, type: :rook}), do: "r"
  def show_piece(%Piece{color: :black, type: :bishop}), do: "b"
  def show_piece(%Piece{color: :black, type: :knight}), do: "n"
  def show_piece(%Piece{color: :black, type: :pawn}), do: "p"
  def show_piece(:empty), do: " "

  def show_unicode_piece(%Piece{color: :white, type: :king}), do: "\u2654"
  def show_unicode_piece(%Piece{color: :white, type: :queen}), do: "\u2655"
  def show_unicode_piece(%Piece{color: :white, type: :rook}), do: "\u2656"
  def show_unicode_piece(%Piece{color: :white, type: :bishop}), do: "\u2657"
  def show_unicode_piece(%Piece{color: :white, type: :knight}), do: "\u2658"
  def show_unicode_piece(%Piece{color: :white, type: :pawn}), do: "\u2659"
  def show_unicode_piece(%Piece{color: :black, type: :king}), do: "\u265A"
  def show_unicode_piece(%Piece{color: :black, type: :queen}), do: "\u265B"
  def show_unicode_piece(%Piece{color: :black, type: :rook}), do: "\u265C"
  def show_unicode_piece(%Piece{color: :black, type: :bishop}), do: "\u265D"
  def show_unicode_piece(%Piece{color: :black, type: :knight}), do: "\u265E"
  def show_unicode_piece(%Piece{color: :black, type: :pawn}), do: "\u265F"
  def show_unicode_piece(:empty), do: " "

  def symbol(%Piece{} = piece) do
    piece
    |> show_piece()
    |> String.upcase()
  end
end
