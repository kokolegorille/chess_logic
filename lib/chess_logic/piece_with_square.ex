defmodule ChessLogic.PieceWithSquare do
  @moduledoc false

  require Bitwise
  alias __MODULE__
  alias ChessLogic.Piece

  @type rank() :: 0..7
  @type file() :: 0..7
  @type square() :: %{rank: rank(), file: file()}

  @type t() :: %PieceWithSquare{
          piece: %Piece{},
          square: square()
        }

  defstruct(
    piece: nil,
    square: nil
  )

  def from_chessfold_piece({:chessfold_piece, pcolor, ptype, sq0x88}) do
    %PieceWithSquare{
      piece: %Piece{ptype: ptype, pcolor: pcolor},
      square: sq0x88_to_square(sq0x88)
    }
  end

  def to_chessfold_piece(%PieceWithSquare{
        piece: %Piece{ptype: ptype, pcolor: pcolor},
        square: square
      }) do
    {:chessfold_piece, pcolor, ptype, square_to_sq0x88(square)}
  end

  def square_to_sq0x88(%{rank: rank, file: file}), do: 16 * rank + file

  def sq0x88_to_square(sq0x88) do
    %{rank: sq0x88_to_rank(sq0x88), file: sq0x88_to_file(sq0x88)}
  end

  # PRIVATE

  defp sq0x88_to_rank(sq0x88), do: Bitwise.>>>(sq0x88, 4)

  defp sq0x88_to_file(sq0x88), do: Bitwise.band(sq0x88, 7)
end
