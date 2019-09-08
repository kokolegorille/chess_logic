defmodule ChessLogic.Square do
  @moduledoc """
  Documentation for Chess.Square.
  Helper functions for square 0x88 notation
  """

  use Bitwise
  alias ChessLogic.Piece

  @row_span 16
  @bottom_left_corner 0
  @top_right_corner 119

  @doc ~S"""
  Returns the square to charlist.
  """
  def square_to_charlist(square) when is_nil(square), do: nil

  def square_to_charlist(%Piece{square: square}), do: square_to_charlist(square)

  def square_to_charlist(square) when square > @top_right_corner,
    do: raise("invalid square number #{square}")

  def square_to_charlist(square) when square < @bottom_left_corner,
    do: raise("invalid square number #{square}")

  def square_to_charlist(square) do
    row_value = div(square, @row_span)
    col_value = rem(square, @row_span)

    [col_value + ?a, row_value + ?1]
  end

  @doc ~S"""
  Returns the square to string.
  """
  def square_to_string(piece_or_square) do
    piece_or_square
    |> square_to_charlist()
    |> to_string()
  end

  @doc ~S"""
  Returns the square from row/col.
  """
  def to_square(%{row: row, col: col}), do: to_square(row, col)

  def to_square(row, col), do: @row_span * row + col

  @doc ~S"""
  Returns the row/col from square or piece.
  """
  def from_square(%Piece{square: square}), do: from_square(square)

  def from_square(square) do
    %{row: square_to_row(square), col: square_to_col(square)}
  end

  defp square_to_row(square), do: Bitwise.>>>(square, 4)

  defp square_to_col(square), do: Bitwise.band(square, 7)

  @doc ~S"""
  Returns the square chars to piece.
  """
  def square_chars_to_pieces(row_string, pieces, row_id),
    do: square_chars_to_pieces(row_string, pieces, row_id * @row_span, row_id * @row_span + 7)

  defp square_chars_to_pieces("", _pieces, current_square_id, last_square_id_of_row)
       when current_square_id - last_square_id_of_row > 1,
       do: raise("too many squares defined #{current_square_id - last_square_id_of_row}")

  defp square_chars_to_pieces("", _pieces, current_square_id, last_square_id_of_row)
       when current_square_id - last_square_id_of_row < 1,
       do: raise("not enough squares defined #{current_square_id - last_square_id_of_row}")

  defp square_chars_to_pieces("", pieces, _, _), do: pieces

  defp square_chars_to_pieces(row_string, pieces, current_square_id, last_square_id_of_row) do
    <<charcode::size(8), remaining::binary>> = row_string

    {square_increment, new_piece} =
      case charcode do
        x when x in [?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8] ->
          {x + 1 - ?1, :empty_square}

        x when x in [?p, ?n, ?b, ?r, ?q, ?k, ?P, ?N, ?B, ?R, ?Q, ?K] ->
          {1, charcode_to_piece(x)}

        _ ->
          raise("Unexpected character: #{charcode}")
      end

    new_pieces =
      case new_piece do
        :empty_square -> pieces
        _ -> [%{new_piece | square: current_square_id} | pieces]
      end

    square_chars_to_pieces(
      remaining,
      new_pieces,
      current_square_id + square_increment,
      last_square_id_of_row
    )
  end

  defp charcode_to_piece(charcode) do
    Piece.read_piece(to_string([charcode]))
  end
end
