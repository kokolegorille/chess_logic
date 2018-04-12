defmodule ChessLogic.CommonTools do
  @moduledoc false
  
  require Bitwise
  
  def string_to_square(string) do
    [file, rank] = string
    |> String.graphemes
    |> Enum.map(&char_to_rank_or_file(&1))
    %{rank: rank, file: file}
  end
  
  def char_to_rank_or_file(char) when char in ["1", "a"], do: 0
  def char_to_rank_or_file(char) when char in ["2", "b"], do: 1
  def char_to_rank_or_file(char) when char in ["3", "c"], do: 2
  def char_to_rank_or_file(char) when char in ["4", "d"], do: 3
  def char_to_rank_or_file(char) when char in ["5", "e"], do: 4
  def char_to_rank_or_file(char) when char in ["6", "f"], do: 5
  def char_to_rank_or_file(char) when char in ["7", "g"], do: 6
  def char_to_rank_or_file(char) when char in ["8", "h"], do: 7
  def char_to_rank_or_file(_char), do: nil
  
  def square_to_sq0x88(%{rank: rank, file: file}), do: 16 * rank + file

  def sq0x88_to_square(sq0x88) do
    %{rank: sq0x88_to_rank(sq0x88), file: sq0x88_to_file(sq0x88)}
  end

  # PRIVATE

  defp sq0x88_to_rank(sq0x88), do: Bitwise.>>>(sq0x88, 4)

  defp sq0x88_to_file(sq0x88), do: Bitwise.band(sq0x88, 7)
end