defmodule ChessLogic.Move do
  @moduledoc """
  Documentation for ChessLogic.Move.
  """

  alias __MODULE__
  alias ChessLogic.{Piece, Position, Square}

  import Square,
    only: [
      square_to_charlist: 1,
      square_to_string: 1,
      from_square: 1
    ]

  # ADDITIONAL
  @san_regex ~r/([BKNPQR])?(([a-h])?([1-8])?)(x)?([a-h])([1-8])(\s*[eE]\.?[pP]\.?\s*)?=?([BNQR])?[\+#]?/
  @coordinates_regex ~r/^([a-h])?([1-8])?([a-h])?([1-8])?$/

  defstruct(
    from: nil,
    to: nil,
    new_position: nil,
    castling: false,
    taken: false
  )

  @doc ~S"""
  Transforms a move to a short algebraic notation. eg. "g1f3" -> "Nf3".
  See : https://chess.stackexchange.com/questions/9470/converting-square-notation-to-algebraic-notation-programmatically
  """
  def move_to_san(moves, move) do
    # In case of promotion... f7f8=Q"
    promotion_piece =
      case String.split(move, "=") do
        [_m, pp] -> charpiece_to_symbol(pp)
        [_m] -> charpiece_to_symbol("Q")
      end

    case select_move(moves, move, promotion_piece) do
      {:ok,
       %Move{
         from: from,
         to: to,
         new_position: new_position,
         castling: castling,
         taken: taken
       }} ->
        # calculate params
        is_promotion = from.type != to.type
        is_long_castling = castling && from_square(to).col == 2
        is_king_attacked = Position.is_king_attacked(new_position)
        all_possibles = Position.all_possible_moves(new_position)
        is_checkmate = is_king_attacked && all_possibles == []
        is_stalemate = !is_king_attacked && all_possibles == []

        if castling do
          castling_reply(is_long_castling)
        else
          pawn_symbol =
            move
            |> String.graphemes()
            |> List.first()

          symbol = Piece.symbol(from)

          buffer =
            ""
            |> piece_symbol(from.type == :pawn, !!taken, pawn_symbol, symbol)
            |> taken_symbol(!!taken)
            |> dest_symbol(square_to_string(to))
            |> promotion_symbol(is_promotion, Piece.symbol(to))
            |> check_symbol(is_checkmate, is_stalemate, is_king_attacked)

          {:ok, buffer}
        end

      {:error, reason} ->
        {:error, "Could not transform move #{move} to san, #{reason}"}
    end
  end

  @doc ~S"""
  Select a move from a list of moves, from a san move.
  This accept san (eg. "e4") or coordinates (eg. "e2e4")

  Returns {:ok, move} | {:error, reason}
  """
  def select_move(moves, coords_or_san, promotion_piece \\ :queen) do
    case Regex.run(@coordinates_regex, coords_or_san) do
      [_, _, _, _, _] -> select_move_by_coordinates(moves, coords_or_san, promotion_piece)
      _ -> select_move_by_san(moves, coords_or_san)
    end
  end

  @doc ~S"""
  Returns a printable string from move
  """
  def move_to_string(%Move{} = move) do
    move
    |> move_to_charlist()
    |> to_string()
  end

  ### PRIVATE

  # Helpers for move_to_san

  defp castling_reply(false), do: {:ok, "O-O"}
  defp castling_reply(true), do: {:ok, "O-O-O"}

  defp check_symbol(buffer, true, _, _), do: buffer <> "#"
  defp check_symbol(buffer, _, true, _), do: buffer <> "="
  defp check_symbol(buffer, _, _, true), do: buffer <> "+"
  defp check_symbol(buffer, _, _, _), do: buffer

  defp dest_symbol(buffer, dest), do: buffer <> dest

  defp taken_symbol(buffer, true), do: buffer <> "x"
  defp taken_symbol(buffer, false), do: buffer

  defp promotion_symbol(buffer, true, symbol), do: "#{buffer}=#{symbol}"
  defp promotion_symbol(buffer, false, _symbol), do: buffer

  def piece_symbol(buffer, true, true, pawn, _piece), do: buffer <> pawn
  def piece_symbol(buffer, true, false, _pawn, _piece), do: buffer
  def piece_symbol(buffer, false, _, _pawn, piece), do: buffer <> piece

  # Helpers for select_move

  defp select_move_by_san([], _), do: {:error, "no moves found"}

  defp select_move_by_san(moves, "O-O") when is_list(moves) do
    [first_move | _tails] = moves

    case first_move.from.color do
      :white -> select_move(moves, "e1g1")
      _ -> select_move(moves, "e8g8")
    end
  end

  defp select_move_by_san(moves, "O-O-O") when is_list(moves) do
    [first_move | _tails] = moves

    case first_move.from.color do
      :white -> select_move_by_coordinates(moves, "e1c1")
      _ -> select_move_by_coordinates(moves, "e8c8")
    end
  end

  defp select_move_by_san(moves, san) when is_list(moves) and is_binary(san) do
    case Regex.run(@san_regex, sanitize_san(san)) do
      [_san, piece, _prefix, from_file, from_rank, _capture, to_rank, to_file] = _splitted_san ->
        filter = fn %Move{
                      from: %Piece{type: from_piece, square: from_square},
                      to: %Piece{square: to_square}
                    } = _move ->
          to_coordinates = square_to_string(to_square)

          [f, r] = square_to_charlist(from_square)
          rank = char_to_rank_or_file(from_rank)
          file = char_to_rank_or_file(from_file)

          to_coordinates == to_rank <> to_file &&
            charpiece_to_symbol(piece) == from_piece &&
            (is_nil(rank) || rank == r - ?1) &&
            (is_nil(file) || file == f - ?a)
        end

        result = moves |> Enum.filter(&filter.(&1))

        case result do
          [] -> {:error, "no move found"}
          [%Move{} = move] -> {:ok, move}
          [_move | _tail] = _moves -> {:error, "ambigous search, found multipe moves"}
        end

      [
        _san,
        piece,
        _prefix,
        from_file,
        from_rank,
        _capture,
        to_rank,
        to_file,
        _ep,
        promoted_piece
      ] = _splitted_san ->
        filter = fn %Move{
                      from: %Piece{type: from_piece, square: from_square},
                      to: %Piece{type: to_piece, square: to_square}
                    } = _move ->
          to_coordinates = square_to_string(to_square)

          [f, r] = square_to_charlist(from_square)
          rank = char_to_rank_or_file(from_rank)
          file = char_to_rank_or_file(from_file)

          to_coordinates == to_rank <> to_file &&
            charpiece_to_symbol(piece) == from_piece &&
            charpiece_to_symbol(promoted_piece) == to_piece &&
            (is_nil(rank) || rank == r - ?1) &&
            (is_nil(file) || file == f - ?a)
        end

        result = moves |> Enum.filter(&filter.(&1))

        case result do
          [] -> {:error, "no move found"}
          [%Move{} = move] -> {:ok, move}
          [_move | _tail] = _moves -> {:error, "ambigous search, found multipe moves"}
        end

      _ ->
        {:error, "Could not select by san #{san}"}
    end
  end

  defp charpiece_to_symbol(charpiece) do
    case charpiece do
      "K" -> :king
      "Q" -> :queen
      "R" -> :rook
      "B" -> :bishop
      "N" -> :knight
      _ -> :pawn
    end
  end

  defp char_to_rank_or_file(char) when char in ["1", "a"], do: 0
  defp char_to_rank_or_file(char) when char in ["2", "b"], do: 1
  defp char_to_rank_or_file(char) when char in ["3", "c"], do: 2
  defp char_to_rank_or_file(char) when char in ["4", "d"], do: 3
  defp char_to_rank_or_file(char) when char in ["5", "e"], do: 4
  defp char_to_rank_or_file(char) when char in ["6", "f"], do: 5
  defp char_to_rank_or_file(char) when char in ["7", "g"], do: 6
  defp char_to_rank_or_file(char) when char in ["8", "h"], do: 7
  defp char_to_rank_or_file(_), do: nil

  defp sanitize_san(san) do
    san
    |> String.trim()
    |> String.replace("+", "")
    |> String.replace("!", "")
    |> String.replace("?", "")
    |> String.replace_trailing("-", "")
    |> String.replace_trailing("=", "")
  end

  defp select_move_by_coordinates(moves, coordinates, promotion_piece \\ :queen)
  defp select_move_by_coordinates([], _, _), do: {:error, "no moves found"}

  defp select_move_by_coordinates(moves, coordinates, promotion_piece)
       when is_list(moves) and is_binary(coordinates) do
    filter_string = to_charlist(coordinates)
    filter = fn m -> move_to_charlist(m) == filter_string end

    result = moves |> Enum.filter(&filter.(&1))

    case result do
      [] ->
        {:error, "no move found"}

      [%Move{} = move] ->
        {:ok, move}

      [_move | _tail] = moves ->
        # Promotion!
        filter_by_promotion_piece(moves, promotion_piece)
    end
  end

  defp filter_by_promotion_piece(moves, promotion_piece) do
    case Enum.filter(moves, fn m -> m.to.type == promotion_piece end) do
      [] -> {:error, "nor move found"}
      [%Move{} = move] -> {:ok, move}
      [_move | _tail] = _moves -> {:error, "ambigous search, found multipe moves"}
    end
  end

  defp move_to_charlist(%Move{from: from, to: to} = _move) do
    square_to_charlist(from) ++ square_to_charlist(to)
  end
end
