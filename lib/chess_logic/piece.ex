defmodule ChessLogic.Piece do
  @moduledoc false

  alias __MODULE__

  @type pcolor() :: :black | :white
  @type ptype() :: :king | :queen | :rook | :bishop | :knight | :pawn
  @type t() :: %Piece{
          pcolor: pcolor(),
          ptype: ptype()
        }

  defstruct(
    pcolor: nil,
    ptype: nil
  )

  @spec read_piece(String.t()) :: t() | :empty
  def read_piece("K"), do: %Piece{pcolor: :white, ptype: :king}
  def read_piece("Q"), do: %Piece{pcolor: :white, ptype: :queen}
  def read_piece("R"), do: %Piece{pcolor: :white, ptype: :rook}
  def read_piece("B"), do: %Piece{pcolor: :white, ptype: :bishop}
  def read_piece("N"), do: %Piece{pcolor: :white, ptype: :knight}
  def read_piece("P"), do: %Piece{pcolor: :white, ptype: :pawn}
  def read_piece("k"), do: %Piece{pcolor: :black, ptype: :king}
  def read_piece("q"), do: %Piece{pcolor: :black, ptype: :queen}
  def read_piece("r"), do: %Piece{pcolor: :black, ptype: :rook}
  def read_piece("b"), do: %Piece{pcolor: :black, ptype: :bishop}
  def read_piece("n"), do: %Piece{pcolor: :black, ptype: :knight}
  def read_piece("p"), do: %Piece{pcolor: :black, ptype: :pawn}
  def read_piece(" "), do: :empty

  @spec show_piece(t() | :empty) :: String.t()
  def show_piece(%Piece{pcolor: :white, ptype: :king}),   do: "K"
  def show_piece(%Piece{pcolor: :white, ptype: :queen}),  do: "Q"
  def show_piece(%Piece{pcolor: :white, ptype: :rook}),   do: "R"
  def show_piece(%Piece{pcolor: :white, ptype: :bishop}), do: "B"
  def show_piece(%Piece{pcolor: :white, ptype: :knight}), do: "N"
  def show_piece(%Piece{pcolor: :white, ptype: :pawn}),   do: "P"
  def show_piece(%Piece{pcolor: :black, ptype: :king}),   do: "k"
  def show_piece(%Piece{pcolor: :black, ptype: :queen}),  do: "q"
  def show_piece(%Piece{pcolor: :black, ptype: :rook}),   do: "r"
  def show_piece(%Piece{pcolor: :black, ptype: :bishop}), do: "b"
  def show_piece(%Piece{pcolor: :black, ptype: :knight}), do: "n"
  def show_piece(%Piece{pcolor: :black, ptype: :pawn}),   do: "p"
  def show_piece(:empty), do: " "
  
  @spec read_piece_type(String.t()) :: atom()
  def read_piece_type("K"), do: :king
  def read_piece_type("Q"), do: :queen
  def read_piece_type("R"), do: :rook
  def read_piece_type("B"), do: :bishop
  def read_piece_type("N"), do: :knight
  def read_piece_type(_),   do: :pawn
  
  @spec show_piece_type(atom()) :: String.t()
  def show_piece_type(:king),   do: "K"
  def show_piece_type(:queen),  do: "Q"
  def show_piece_type(:rook),   do: "R"
  def show_piece_type(:bishop), do: "B"
  def show_piece_type(:knight), do: "N"
  def show_piece_type(_),       do: "p"
end
