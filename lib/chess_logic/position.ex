defmodule ChessLogic.Position do
  @moduledoc """
  Documentation for Position.
  """

  use Bitwise
  alias __MODULE__
  alias ChessLogic.{Piece, Move, Square}

  import Square,
  only: [
    square_to_string: 1,
    square_chars_to_pieces: 3,
    to_square: 2
  ]

  @initial_fen_position "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  @row_span 16
  @move_up 16
  @move_up_left 15
  @move_up_right 17
  @move_up_2 32
  @move_down -16
  @move_down_left -17
  @move_down_right -15
  @move_down_2 -32
  @bottom_left_corner 0
  @bottom_right_corner 7
  @top_left_corner 112
  @top_right_corner 119

  @castling_all 15
  @castling_white_king 8
  @castling_white_queen 4
  @castling_black_king 2
  @castling_black_queen 1

  # Attack- and delta-array and constants (source: Jonatan Pettersson (mediocrechess@gmail.com))
  # Deltas that no piece can move
  @attack_none 0
  # One square up down left and right
  @attack_kqr 1
  # More than one square up down left and right
  @attack_qr 2
  # One square diagonally up
  @attack_kqbwp 3
  # One square diagonally down
  @attack_kqbbp 4
  # More than one square diagonally
  @attack_qb 5
  # Knight moves
  @attack_n 6

  # Code.eval_string is used to preserve data structure from being formatted
  # https://elixirforum.com/t/configure-formatter-to-ignore-some-part-of-code/16081

  # Formula: attacked_square - attacking_square + 128 = pieces able to attack
  @attack_array Code.eval_string("""
                [
                  0,0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,2,0,0,0, # 0-19
                  0,0,0,5,0,0,5,0,0,0,0,0,2,0,0,0,0,0,5,0, # 20-39
                  0,0,0,5,0,0,0,0,2,0,0,0,0,5,0,0,0,0,0,0, # 40-59
                  5,0,0,0,2,0,0,0,5,0,0,0,0,0,0,0,0,5,0,0, # 60-79
                  2,0,0,5,0,0,0,0,0,0,0,0,0,0,5,6,2,6,5,0, # 80-99
                  0,0,0,0,0,0,0,0,0,0,6,4,1,4,6,0,0,0,0,0, # 100-119
                  0,2,2,2,2,2,2,1,0,1,2,2,2,2,2,2,0,0,0,0, # 120-139
                  0,0,6,3,1,3,6,0,0,0,0,0,0,0,0,0,0,0,5,6, # 140-159
                  2,6,5,0,0,0,0,0,0,0,0,0,0,5,0,0,2,0,0,5, # 160-179
                  0,0,0,0,0,0,0,0,5,0,0,0,2,0,0,0,5,0,0,0, # 180-199
                  0,0,0,5,0,0,0,0,2,0,0,0,0,5,0,0,0,0,5,0, # 200-219
                  0,0,0,0,2,0,0,0,0,0,5,0,0,5,0,0,0,0,0,0, # 220-239
                  2,0,0,0,0,0,0,5,0,0,0,0,0,0,0,0,0        # 240-256
                ]
                """)
                |> elem(0)

  # Same as attack array but gives the delta needed to get to the square
  @delta_array Code.eval_string("""
              [
                0,   0,   0,   0,   0,   0,   0,   0,   0, -17,   0,   0,   0,   0,   0,   0, -16,   0,   0,   0,
                0,   0,   0, -15,   0,   0, -17,   0,   0,   0,   0,   0, -16,   0,   0,   0,   0,   0, -15,   0,
                0,   0,   0, -17,   0,   0,   0,   0, -16,   0,   0,   0,   0, -15,   0,   0,   0,   0,   0,   0,
                -17,   0,   0,   0, -16,   0,   0,   0, -15,   0,   0,   0,   0,   0,   0,   0,   0, -17,   0,   0,
                -16,   0,   0, -15,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, -17, -33, -16, -31, -15,   0,
                0,   0,   0,   0,   0,   0,   0,   0,   0,   0, -18, -17, -16, -15, -14,   0,   0,   0,   0,   0,
                0,  -1,  -1,  -1,  -1,  -1,  -1,  -1,   0,   1,   1,   1,   1,   1,   1,   1,   0,   0,   0,   0,
                0,   0,  14,  15,  16,  17,  18,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  15,  31,
                16,  33,  17,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,  15,   0,   0,  16,   0,   0,  17,
                0,   0,   0,   0,   0,   0,   0,   0,  15,   0,   0,   0,  16,   0,   0,   0,  17,   0,   0,   0,
                0,   0,   0,  15,   0,   0,   0,   0,  16,   0,   0,   0,   0,  17,   0,   0,   0,   0,  15,   0,
                0,   0,   0,   0,  16,   0,   0,   0,   0,   0,  17,   0,   0,  15,   0,   0,   0,   0,   0,   0,
                16,   0,   0,   0,   0,   0,   0,  17,   0,   0,   0,   0,   0,   0,   0,   0,   0
              ]
              """)
              |> elem(0)

  defstruct(
    pieces: [],
    turn: :white,
    allowed_castling: 0,
    en_passant_square: nil,
    half_move_clock: 0,
    move_number: 0
  )

  @doc ~S"""
  Returns a san from a move string, given a set of possible moves.
  Game history persists a san version of move, for PGN export
  eg. "e2e4" -> "e4", "e4" -> "e4"
  """
  def move_to_san(position, move) do
    moves = all_possible_moves(position)
    Move.move_to_san(moves, move)
  end

  @doc ~S"""
  Returns a coords move (eg. "e2e4") from san (eg. "e4")
  """
  def san_to_move(position, san) do
    moves = all_possible_moves(position)

    case Move.select_move(moves, san) do
      {:ok, move} -> {:ok, Move.move_to_string(move)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc ~S"""
  Returns a position from a fen string.
  """
  def from_fen(fen \\ @initial_fen_position) do
    case String.split(fen, " ") do
      [board_string, turn_string, allowed_castling_string, en_passant_string | remaining] ->
        {half_move_clock, move_number} = remaining_string_to_value(remaining)

        %Position{
          pieces: board_string_to_pieces(board_string),
          turn: turn_string_to_value(turn_string),
          allowed_castling: allowed_castling_string_to_value(allowed_castling_string),
          en_passant_square: en_passant_string_to_value(en_passant_string),
          half_move_clock: half_move_clock,
          move_number: move_number
        }

      _ ->
        :error
    end
  end

  @doc ~S"""
  Returns a fen string from a position.
  """
  def to_fen(%Position{half_move_clock: half_move_clock, move_number: move_number} = position) do
    Enum.join(
      [
        to_fen_without_counters(position),
        to_string(half_move_clock),
        to_string(move_number)
      ],
      " "
    )
  end

  @doc ~S"""
  Returns position status.
  """
  def status(%Position{half_move_clock: half_move_clock} = position) do
    is_in_check = is_king_attacked(position)

    cond do
      half_move_clock >= 100 -> :draw
      length(all_possible_moves(position)) > 0 -> :in_progress
      is_in_check -> :checkmate
      !is_in_check -> :draw
    end
  end

  @doc ~S"""
  Returns all possible moves from a position.
  """
  def all_possible_moves(%Position{} = position) do
    position
    |> all_pseudo_legal_moves()
    |> eliminate_illegal_moves()
  end

  def all_possible_moves(fen) when is_binary(fen) do
    fen
    |> from_fen()
    |> all_possible_moves
  end

  @doc ~S"""
  Returns all possible moves from a given piece, or square.
  """
  def all_possible_moves_from(%Position{} = position, %Piece{} = start_piece) do
    accumulate_pseudo_legal_moves_of_piece(position, start_piece, [])
    |> eliminate_illegal_moves()
  end

  def all_possible_moves_from(%Position{pieces: pieces} = position, start_square) do
    get_piece_on_square(pieces, start_square)
    |> (fn p -> all_possible_moves_from(position, p) end).()
  end

  @doc ~S"""
  Check if king is attacked.
  """
  def is_king_attacked(%Position{pieces: pieces, turn: player_color} = position) do
    is_square_in_attack(pieces, opponent_color(position), king_square(pieces, player_color))
  end

  def is_king_attacked(fen) when is_binary(fen) do
    fen
    |> from_fen()
    |> is_king_attacked()
  end

  @doc ~S"""
  Plays a move and returns new position.
  """
  def play(%Position{} = position, move) do
    selected_move =
      position
      |> all_possible_moves()
      |> Move.select_move(move)

    case selected_move do
      {:ok, m} -> {:ok, m.new_position}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc ~S"""
  Prints a position.
  """
  def print(%Position{pieces: pieces} = _position) do
    for row <- 7..0, col <- 0..7 do
      square_key = 16 * row + col

      piece =
        pieces
        |> Enum.filter(fn p -> p.square == square_key end)
        |> List.first()

      Piece.show_unicode_piece(piece || :empty)
    end
    |> Enum.chunk_every(8)
    |> Enum.map(&Enum.join(&1, " "))
    |> Enum.join("\n")
    |> IO.puts()
  end

  ## From Fen

  defp remaining_string_to_value([hmc_char, mn_char]),
    do: {String.to_integer(hmc_char), String.to_integer(mn_char)}

  defp remaining_string_to_value([hmc_char]),
    do: {String.to_integer(hmc_char), 1}

  defp remaining_string_to_value([]), do: {0, 1}

  defp turn_string_to_value("w"), do: :white

  defp turn_string_to_value("b"), do: :black

  defp allowed_castling_string_to_value(allowed_castling_string) do
    allowed_castling_string
    |> String.graphemes()
    |> Enum.reduce(0, fn char, acc ->
      case char do
        "K" -> acc + @castling_white_king
        "Q" -> acc + @castling_white_queen
        "k" -> acc + @castling_black_king
        "q" -> acc + @castling_black_queen
        _ -> acc
      end
    end)
  end

  defp en_passant_string_to_value("-"), do: nil

  defp en_passant_string_to_value(<<c::size(8), r::size(8)>>)
      when c >= ?a and c <= ?h and r >= ?1 and r <= ?8,
      do: to_square(r - ?1, c - ?a)

  defp en_passant_string_to_value(_), do: nil

  # defp to_square(row, col), do: @row_span * row + col

  defp board_string_to_pieces(board_string) do
    board_string
    |> String.split("/")
    |> Enum.reverse()
    |> row_strings_to_pieces()
  end

  defp row_strings_to_pieces(row_strings), do: row_strings_to_pieces(row_strings, [], 0)

  defp row_strings_to_pieces([], pieces, 8), do: pieces

  defp row_strings_to_pieces([], _, row_id) when row_id < 8,
    do: raise("too many rows defined #{row_id}")

  defp row_strings_to_pieces([], _, row_id) when row_id > 8,
    do: raise("not enough rows defined #{row_id}")

  defp row_strings_to_pieces(row_strings, pieces, row_id) do
    [row_string | remaining] = row_strings

    row_strings_to_pieces(
      remaining,
      square_chars_to_pieces(row_string, pieces, row_id),
      row_id + 1
    )
  end

  ## To Fen

  defp to_fen_without_counters(%Position{
        pieces: pieces,
        turn: turn,
        allowed_castling: allowed_castling,
        en_passant_square: en_passant_square
      }) do
    Enum.join(
      [
        pieces_to_board_string(pieces),
        turn_value_to_string(turn),
        allowed_castling_value_to_string(allowed_castling),
        en_passant_square_to_string(en_passant_square)
      ],
      " "
    )
  end

  defp pieces_to_board_string(pieces) do
    pieces_to_row_strings(pieces)
    |> Enum.join("/")
  end

  defp pieces_to_row_strings(pieces), do: pieces_to_row_strings(pieces, 0, [])

  defp pieces_to_row_strings(_, 8, acc), do: acc

  defp pieces_to_row_strings(pieces, row_id, acc) do
    new_row = chess_grid_to_row_chars(pieces, row_id)
    pieces_to_row_strings(pieces, row_id + 1, [new_row | acc])
  end

  defp chess_grid_to_row_chars(pieces, row_id),
    do: chess_grid_to_row_chars(pieces, row_id, 7, [], 0)

  defp chess_grid_to_row_chars(_, _, -1, acc, counter) do
    case counter do
      0 -> acc
      _ -> [to_string(counter) | acc]
    end
    |> Enum.join("")
  end

  defp chess_grid_to_row_chars(pieces, row_id, col_id, acc, counter) do
    square = to_square(row_id, col_id)

    piece_char =
      case get_piece_on_square(pieces, square) do
        false -> false
        piece -> Piece.show_piece(piece)
      end

    {new_acc, new_counter} =
      case {piece_char, counter} do
        {false, _} -> {acc, counter + 1}
        {_, 0} -> {[piece_char | acc], 0}
        _ -> {[piece_char, to_string(counter) | acc], 0}
      end

    chess_grid_to_row_chars(pieces, row_id, col_id - 1, new_acc, new_counter)
  end

  defp get_piece_on_square(%Position{pieces: pieces}, square_key),
    do: get_piece_on_square(pieces, square_key)

  defp get_piece_on_square(pieces, square) when is_list(pieces) do
    piece =
      pieces
      |> Enum.filter(fn p -> p.square == square end)
      |> List.first()

    if is_nil(piece), do: false, else: piece
  end

  defp turn_value_to_string(:white), do: "w"

  defp turn_value_to_string(:black), do: "b"

  defp en_passant_square_to_string(nil_or_false)
      when is_nil(nil_or_false) or not nil_or_false,
      do: "-"

  defp en_passant_square_to_string(""), do: "-"

  defp en_passant_square_to_string(square) do
    square_to_string(square)
  end

  defp allowed_castling_value_to_string(allowed_castling) do
    allowed_castling_string =
      Enum.join([
        calculate_castling(allowed_castling, @castling_white_king, "K"),
        calculate_castling(allowed_castling, @castling_white_queen, "Q"),
        calculate_castling(allowed_castling, @castling_black_king, "k"),
        calculate_castling(allowed_castling, @castling_black_queen, "q")
      ])

    case allowed_castling_string do
      "" -> "-"
      allowed_castling_string -> allowed_castling_string
    end
  end

  defp calculate_castling(allowed_castling, castling, success_string) do
    case band(allowed_castling, castling) do
      0 -> ""
      _ -> success_string
    end
  end

  ## All possible moves

  defp all_pseudo_legal_moves(%Position{pieces: pieces, turn: turn} = position) do
    player_pieces = pieces_of_color(pieces, turn)

    player_pieces
    |> Enum.reduce([], fn (player_piece, move_list) ->
      accumulate_pseudo_legal_moves_of_piece(position, player_piece, move_list)
    end)
  end

  defp accumulate_pseudo_legal_moves_of_piece(
        position,
        %Piece{color: piece_color, type: piece_type} = moved_piece,
        move_list_acc
      ) do
    opponent = opponent_color(position)

    case {piece_color, piece_type} do
      {^opponent, _} -> move_list_acc
      {_, :pawn} -> accumulate_pseudo_legal_pawn_moves(position, moved_piece, move_list_acc)
      {_, :rook} -> accumulate_pseudo_legal_rook_moves(position, moved_piece, move_list_acc)
      {_, :knight} -> accumulate_pseudo_legal_knight_moves(position, moved_piece, move_list_acc)
      {_, :bishop} -> accumulate_pseudo_legal_bishop_moves(position, moved_piece, move_list_acc)
      {_, :queen} -> accumulate_pseudo_legal_queen_moves(position, moved_piece, move_list_acc)
      {_, :king} -> accumulate_pseudo_legal_king_moves(position, moved_piece, move_list_acc)
      _ -> raise({:error, "invalid piece type #{piece_type}"})
    end
  end

  defp accumulate_pseudo_legal_pawn_moves(
        %Position{turn: turn, en_passant_square: en_passant_square} = position,
        %Piece{square: square} = moved_piece,
        move_list_acc
      ) do
    {row_id, col_id} = {div(square, @row_span), rem(square, @row_span)}

    next_row =
      case turn do
        :white -> row_id + 1
        _ -> row_id - 1
      end

    {increment, other_increment, is_promotion} =
      case {turn, row_id} do
        # absurd in normal play
        {:white, 7} ->
          {false, false, false}

        # absurd in normal play
        {:black, 0} ->
          {false, false, false}

        {:white, 1} ->
          {@move_up, @move_up_2, false}

        {:white, 6} ->
          {@move_up, false, true}

        {:black, 6} ->
          {@move_down, @move_down_2, false}

        {:black, 1} ->
          {@move_down, false, true}

        {:white, _} ->
          {@move_up, false, false}

        {:black, _} ->
          {@move_down, false, false}
      end

    # Forward moves, including initial two-row move, resulting in en-passant for the next player

    {move_list_with_forward_1, forward_2_is_blocked} =
      case increment do
        false ->
          {move_list_acc, true}

        _ ->
          new_square_1 = square + increment

          case square_has_piece(position, new_square_1) do
            true ->
              {move_list_acc, true}

            _ ->
              {insert_pseudo_legal_move(
                move_list_acc,
                position,
                moved_piece,
                %{moved_piece | square: new_square_1},
                false,
                false,
                false,
                is_promotion
              ), false}
          end
      end

    move_list_with_forward_2 =
      case {forward_2_is_blocked, other_increment} do
        {true, _} ->
          move_list_with_forward_1

        {_, false} ->
          move_list_with_forward_1

        _ ->
          new_square_2 = square + other_increment

          case square_has_piece(position, new_square_2) do
            true ->
              move_list_with_forward_1

            _ ->
              insert_pseudo_legal_move(
                move_list_with_forward_1,
                position,
                moved_piece,
                %{moved_piece | square: new_square_2},
                false,
                false,
                square + increment,
                false
              )
          end
      end

    # Taking moves
    opponent = opponent_color(position)

    move_list_with_left_taking =
      case col_id do
        0 ->
          move_list_with_forward_2

        _ ->
          # Try to take on the left
          left_square = to_square(next_row, col_id - 1)
          left_taken_piece = get_piece_on_square(position, left_square)

          case {left_taken_piece, en_passant_square} do
            # Don't forget the caret!
            {_, ^left_square} ->
              # En passant
              insert_pseudo_legal_move(
                move_list_with_forward_2,
                position,
                moved_piece,
                %{moved_piece | square: left_square},
                %Piece{
                  color: opponent,
                  type: :pawn,
                  square: to_square(row_id, col_id - 1)
                },
                false,
                false,
                false
              )

            {false, _} ->
              move_list_with_forward_2

            _ ->
              if left_taken_piece.color == turn do
                move_list_with_forward_2
              else
                insert_pseudo_legal_move(
                  move_list_with_forward_2,
                  position,
                  moved_piece,
                  %{moved_piece | square: left_square},
                  left_taken_piece,
                  false,
                  false,
                  is_promotion
                )
              end
          end
      end

    case col_id do
      7 ->
        move_list_with_left_taking

      _ ->
        # Try to take on the right
        right_square = to_square(next_row, col_id + 1)
        right_taken_piece = get_piece_on_square(position, right_square)

        case {right_taken_piece, en_passant_square} do
          # Don't forget the caret!
          {_, ^right_square} ->
            # En passant
            insert_pseudo_legal_move(
              move_list_with_left_taking,
              position,
              moved_piece,
              %{moved_piece | square: right_square},
              %Piece{color: opponent, type: :pawn, square: to_square(row_id, col_id + 1)},
              false,
              false,
              false
            )

          {false, _} ->
            move_list_with_left_taking

          _ ->
            if right_taken_piece.color == turn do
              move_list_with_left_taking
            else
              insert_pseudo_legal_move(
                move_list_with_left_taking,
                position,
                moved_piece,
                %{moved_piece | square: right_square},
                right_taken_piece,
                false,
                false,
                is_promotion
              )
            end
        end
    end
  end

  defp accumulate_pseudo_legal_rook_moves(
        %Position{turn: turn} = position,
        %Piece{square: square} = moved_piece,
        move_list_acc
      ) do
    move_list_acc
    |> accumulate_moves(position, moved_piece, square, -1, turn, true)
    |> accumulate_moves(position, moved_piece, square, 1, turn, true)
    |> accumulate_moves(position, moved_piece, square, -@row_span, turn, true)
    |> accumulate_moves(position, moved_piece, square, @row_span, turn, true)
  end

  defp accumulate_pseudo_legal_knight_moves(
        %Position{turn: turn} = position,
        %Piece{square: square} = moved_piece,
        move_list_acc
      ) do
    move_list_acc
    |> accumulate_moves(position, moved_piece, square, -33, turn, false)
    # 32 + 1 (0x88 representation)
    |> accumulate_moves(position, moved_piece, square, 33, turn, false)
    |> accumulate_moves(position, moved_piece, square, -31, turn, false)
    # 32 - 1 (0x88 representation)
    |> accumulate_moves(position, moved_piece, square, 31, turn, false)
    |> accumulate_moves(position, moved_piece, square, -18, turn, false)
    # 16 + 2 (0x88 representation)
    |> accumulate_moves(position, moved_piece, square, 18, turn, false)
    |> accumulate_moves(position, moved_piece, square, -14, turn, false)
    # 16 - 2 (0x88 representation)
    |> accumulate_moves(position, moved_piece, square, 14, turn, false)
  end

  defp accumulate_pseudo_legal_bishop_moves(
        %Position{turn: turn} = position,
        %Piece{square: square} = moved_piece,
        move_list_acc
      ) do
    move_list_acc
    |> accumulate_moves(position, moved_piece, square, @move_down_left, turn, true)
    |> accumulate_moves(position, moved_piece, square, @move_up_right, turn, true)
    |> accumulate_moves(position, moved_piece, square, @move_down_right, turn, true)
    |> accumulate_moves(position, moved_piece, square, @move_up_left, turn, true)
  end

  defp accumulate_pseudo_legal_queen_moves(position, moved_piece, move_list_acc) do
    # Don't forget to call the anonymous funtion in the pipe!
    move_list_acc
    # Because move_acc_list is at the end!
    |> (fn x -> accumulate_pseudo_legal_rook_moves(position, moved_piece, x) end).()
    # Because move_acc_list is at the end!
    |> (fn x -> accumulate_pseudo_legal_bishop_moves(position, moved_piece, x) end).()
  end

  defp accumulate_pseudo_legal_king_moves(
        %Position{turn: turn, allowed_castling: allowed_castling} = position,
        %Piece{square: square} = moved_piece,
        move_list_acc
      ) do
    move_list_acc
    |> accumulate_moves(position, moved_piece, square, @move_down_left, turn, false)
    |> accumulate_moves(position, moved_piece, square, @move_up_right, turn, false)
    |> accumulate_moves(position, moved_piece, square, @move_down_right, turn, false)
    |> accumulate_moves(position, moved_piece, square, @move_up_left, turn, false)
    |> accumulate_moves(position, moved_piece, square, -1, turn, false)
    |> accumulate_moves(position, moved_piece, square, 1, turn, false)
    |> accumulate_moves(position, moved_piece, square, @move_down, turn, false)
    |> accumulate_moves(position, moved_piece, square, @move_up, turn, false)
    |> queen_side_castling(position, moved_piece, allowed_castling)
    |> king_side_castling(position, moved_piece, allowed_castling)
  end

  # puts move_list_acc as first param for easy pipe!
  # This will also change params order from original function
  defp king_side_castling(
        move_list_acc,
        %Position{turn: turn} = position,
        %Piece{square: square} = moved_piece,
        allowed_castling
      ) do
    turn_king =
      case turn do
        :white -> @castling_white_king
        _ -> @castling_black_king
      end

    case band(turn_king, allowed_castling) do
      0 ->
        move_list_acc

      _ ->
        piece_on_column_f = get_piece_on_square(position, square + 1)
        piece_on_column_g = get_piece_on_square(position, square + 2)

        cond do
          piece_on_column_f != false ->
            move_list_acc

          piece_on_column_g != false ->
            move_list_acc

          true ->
            insert_pseudo_legal_move(
              move_list_acc,
              position,
              moved_piece,
              %{moved_piece | square: square + 2},
              false,
              :king,
              false,
              false
            )
        end
    end
  end

  defp queen_side_castling(
        move_list_acc,
        %Position{turn: turn} = position,
        %Piece{square: square} = moved_piece,
        allowed_castling
      ) do
    turn_queen =
      case turn do
        :white -> @castling_white_queen
        _ -> @castling_black_queen
      end

    case band(turn_queen, allowed_castling) do
      0 ->
        move_list_acc

      _ ->
        piece_on_column_d = get_piece_on_square(position, square - 1)
        piece_on_column_c = get_piece_on_square(position, square - 2)
        piece_on_column_b = get_piece_on_square(position, square - 3)

        cond do
          piece_on_column_d != false ->
            move_list_acc

          piece_on_column_c != false ->
            move_list_acc

          piece_on_column_b != false ->
            move_list_acc

          true ->
            insert_pseudo_legal_move(
              move_list_acc,
              position,
              moved_piece,
              %{moved_piece | square: square - 2},
              false,
              :queen,
              false,
              false
            )
        end
    end
  end

  # puts move_list_acc as first param for easy pipe!
  # This will also change params order from original function
  defp accumulate_moves(_, _, _, _, 0, _, _), do: raise("invalid increment 0")

  defp accumulate_moves(
        move_list_acc,
        position,
        moved_piece,
        current_square,
        increment,
        turn,
        continue
      ) do
    new_square = current_square + increment

    case is_border_reached(new_square) do
      true ->
        move_list_acc

      _ ->
        occupying_piece = get_piece_on_square(position, new_square)

        case occupying_piece do
          %Piece{color: color} when color == turn ->
            move_list_acc

          false ->
            new_move_list =
              insert_pseudo_legal_move(
                move_list_acc,
                position,
                moved_piece,
                %{moved_piece | square: new_square},
                false,
                false,
                false,
                false
              )

            if continue do
              accumulate_moves(
                new_move_list,
                position,
                moved_piece,
                new_square,
                increment,
                turn,
                continue
              )
            else
              new_move_list
            end

          _ ->
            insert_pseudo_legal_move(
              move_list_acc,
              position,
              moved_piece,
              %{moved_piece | square: new_square},
              occupying_piece,
              false,
              false,
              false
            )
        end
    end
  end

  # Promotion
  defp insert_pseudo_legal_move(
        move_list_acc,
        position,
        from,
        to,
        taken,
        _castling,
        _new_en_passant,
        true
      ) do
    move_list_acc
    |> insert_pseudo_legal_move(position, from, %{to | type: :knight}, taken, false, false, false)
    |> insert_pseudo_legal_move(position, from, %{to | type: :bishop}, taken, false, false, false)
    |> insert_pseudo_legal_move(position, from, %{to | type: :rook}, taken, false, false, false)
    |> insert_pseudo_legal_move(position, from, %{to | type: :queen}, taken, false, false, false)
  end

  # Not a promotion
  defp insert_pseudo_legal_move(
        move_list_acc,
        position,
        from,
        to,
        taken,
        castling,
        new_en_passant,
        false
      ) do
    new_position = get_new_position(position, from, to, taken, castling, new_en_passant)

    move = %Move{
      from: from,
      to: to,
      new_position: new_position,
      castling: castling,
      taken: taken
    }

    [move | move_list_acc]
  end

  defp get_new_position(
        %Position{
          pieces: pieces,
          turn: turn,
          allowed_castling: allowed_castling,
          half_move_clock: half_move_clock,
          move_number: move_number
        },
        from,
        to,
        taken,
        castling,
        new_en_passant
      ) do
    # Delete taken piece
    new_pieces1 =
      case taken do
        # n when n in [false, nil] -> pieces
        false ->
          pieces

        _ ->
          pieces |> Enum.reject(fn p -> p.square == taken.square end)
      end

    # Move piece
    new_pieces2 = move_piece(new_pieces1, from, to)

    # In case of castling, move the rook as well
    new_pieces3 =
      case castling do
        false ->
          new_pieces2

        :queen ->
          rook_square = from.square - 4
          rook_from = %Piece{color: turn, type: :rook, square: rook_square}
          rook_to = %Piece{color: turn, type: :rook, square: rook_square + 3}
          move_piece(new_pieces2, rook_from, rook_to)

        :king ->
          rook_square = from.square + 3
          rook_from = %Piece{color: turn, type: :rook, square: rook_square}
          rook_to = %Piece{color: turn, type: :rook, square: rook_square - 2}
          move_piece(new_pieces2, rook_from, rook_to)
      end

    # Calculate new castling information
    eliminated_castling_of_player =
      case {from.type, from.color, from.square} do
        {:king, :white, _} -> bor(@castling_white_queen, @castling_white_king)
        {:king, _, _} -> bor(@castling_black_queen, @castling_black_king)
        {:rook, _, @bottom_left_corner} -> @castling_white_queen
        {:rook, _, @bottom_right_corner} -> @castling_white_king
        {:rook, _, @top_left_corner} -> @castling_black_queen
        {:rook, _, @top_right_corner} -> @castling_black_king
        _ -> 0
      end

    filter1 = bxor(@castling_all, eliminated_castling_of_player)

    # Calculate the opponent's new castling information (if a tower is taken)
    eliminated_castling_of_opponent =
      case taken do
        false ->
          0

        %Piece{color: victim_color, type: victim_type} ->
          case victim_type do
            :rook ->
              calculate_castling(
                to.square - victim_left_square(victim_color),
                victim_color
              )

            _ ->
              0
          end
      end

    filter2 = bxor(@castling_all, eliminated_castling_of_opponent)

    new_allowed_castling =
      allowed_castling
      |> band(filter1)
      |> band(filter2)

    # Update turn and move number
    {new_turn, new_move_number} =
      case turn do
        :white -> {:black, move_number}
        _ -> {:white, move_number + 1}
      end

    # Update half-move clock
    new_half_move_clock =
      cond do
        taken != false -> 0
        from.type == :pawn -> 0
        true -> half_move_clock + 1
      end

    %Position{
      pieces: new_pieces3,
      turn: new_turn,
      allowed_castling: new_allowed_castling,
      en_passant_square: new_en_passant,
      half_move_clock: new_half_move_clock,
      move_number: new_move_number
    }
  end

  defp victim_left_square(:black), do: 112
  defp victim_left_square(_), do: 0

  defp calculate_castling(0, :white), do: @castling_white_queen
  defp calculate_castling(0, _), do: @castling_black_queen
  defp calculate_castling(7, :white), do: @castling_white_king
  defp calculate_castling(7, _), do: @castling_black_king
  defp calculate_castling(_, _), do: 0

  defp move_piece(pieces, %Piece{square: from_square} = _from, %Piece{} = to)
      when is_list(pieces) do
    new_pieces =
      pieces
      |> Enum.reject(fn p -> p.square == from_square end)

    [to | new_pieces]
  end

  defp is_border_reached(square) do
    # 16#88 = 136
    case band(square, 136) do
      0 -> false
      _ -> true
    end
  end

  defp eliminate_illegal_moves(moves), do: eliminate_illegal_moves(moves, [])
  defp eliminate_illegal_moves([], legal_moves_acc), do: legal_moves_acc

  defp eliminate_illegal_moves([move | remaining_moves] = _moves, legal_moves_acc) do
    # Determine if there is an attack *after* the move
    pieces = move.new_position.pieces
    player_color = move.from.color
    opponent_color = move.new_position.turn

    # The king of the player who has *just played*, i.e. not the same king as if we called is_king_attacked on the resulting position
    kg_square = king_square(pieces, player_color)
    player_king_attacked = is_square_in_attack(pieces, opponent_color, kg_square)

    # In case of castling, verify the start and median square as well
    start_square = move.from.square

    illegal =
      case {player_king_attacked, move.castling} do
        {true, _} ->
          true

        {false, false} ->
          false

        {false, :king} ->
          is_any_square_in_attack(pieces, opponent_color, [start_square, start_square + 1])

        {false, :queen} ->
          is_any_square_in_attack(pieces, opponent_color, [start_square, start_square - 1])
      end

    case illegal do
      false -> eliminate_illegal_moves(remaining_moves, [move | legal_moves_acc])
      _ -> eliminate_illegal_moves(remaining_moves, legal_moves_acc)
    end
  end

  defp is_any_square_in_attack(_pieces, _attacking_piece_color, []), do: false

  defp is_any_square_in_attack(pieces, attacking_piece_color, targets) do
    [target | remaining_targets] = targets

    case is_square_in_attack(pieces, attacking_piece_color, target) do
      true -> true
      _ -> is_any_square_in_attack(pieces, attacking_piece_color, remaining_targets)
    end
  end

  ## Check if king is attacked.

  defp king_square(pieces, king_color) do
    the_func = fn piece ->
      case {piece.color, piece.type} do
        {^king_color, :king} -> true
        _ -> false
      end
    end

    case Enum.filter(pieces, the_func) do
      [player_king] -> player_king.square
      _ -> false
    end
  end

  defp square_has_piece(%Position{pieces: pieces}, square_key),
    do: square_has_piece(pieces, square_key)

  defp square_has_piece(pieces, square_key) when is_list(pieces) do
    piece = get_piece_on_square(pieces, square_key)

    case piece do
      false -> false
      _ -> true
    end
  end

  defp is_square_in_attack(pieces, attacking_piece_color, attacked_square) do
    opponent_pieces = pieces_of_color(pieces, attacking_piece_color)

    the_func = fn piece, is_already_in_attack ->
      case is_already_in_attack do
        true ->
          true

        false ->
          attacking_square = piece.square

          attack_array_key =
            try do
              attacked_square - attacking_square + 129
            rescue
              e in ArithmeticError ->
                IO.puts("is_square_in_attack error : #{inspect(e)}")
                0
            end

          # Erlang lists:nth starts at 1!
          # PiecesAbleToAttack  = lists:nth(AttackArrayKey, ?ATTACK_ARRAY),
          pieces_able_to_attack = Enum.at(@attack_array, attack_array_key - 1)
          attacking_piece_type = piece.type

          increment = Enum.at(@delta_array, attack_array_key - 1)
          default = !is_piece_on_the_way(pieces, attacking_square, attacked_square, increment)

          is_possible_attack_with_attacking_piece_type(
            {
              is_possible_attack(
                {pieces_able_to_attack, attacking_piece_color, attacking_piece_type}
              ),
              attacking_piece_type
            },
            default
          )
      end
    end

    opponent_pieces |> List.foldl(false, the_func)
  end

  defp is_possible_attack_with_attacking_piece_type({false, _}, _default), do: false
  defp is_possible_attack_with_attacking_piece_type({true, :pawn}, _default), do: true
  defp is_possible_attack_with_attacking_piece_type({true, :knight}, _default), do: true
  defp is_possible_attack_with_attacking_piece_type({true, :king}, _default), do: true
  defp is_possible_attack_with_attacking_piece_type(_, default), do: default

  defp is_possible_attack({@attack_none, _, _}), do: false
  defp is_possible_attack({@attack_kqr, _, :king}), do: true
  defp is_possible_attack({@attack_kqr, _, :queen}), do: true
  defp is_possible_attack({@attack_kqr, _, :rook}), do: true
  defp is_possible_attack({@attack_qr, _, :queen}), do: true
  defp is_possible_attack({@attack_qr, _, :rook}), do: true
  defp is_possible_attack({@attack_kqbwp, _, :king}), do: true
  defp is_possible_attack({@attack_kqbwp, _, :queen}), do: true
  defp is_possible_attack({@attack_kqbwp, _, :bishop}), do: true
  defp is_possible_attack({@attack_kqbwp, :white, :pawn}), do: true
  defp is_possible_attack({@attack_kqbbp, _, :king}), do: true
  defp is_possible_attack({@attack_kqbbp, _, :queen}), do: true
  defp is_possible_attack({@attack_kqbbp, _, :bishop}), do: true
  defp is_possible_attack({@attack_kqbbp, :black, :pawn}), do: true
  defp is_possible_attack({@attack_qb, _, :queen}), do: true
  defp is_possible_attack({@attack_qb, _, :bishop}), do: true
  defp is_possible_attack({@attack_n, _, :knight}), do: true
  defp is_possible_attack(_), do: false

  defp is_piece_on_the_way(_pieces, square1, square2, _increment)
      when square1 == square2,
      do: false

  defp is_piece_on_the_way(_pieces, square1, square2, increment)
      when square1 + increment == square2,
      do: false

  defp is_piece_on_the_way(pieces, square1, square2, increment) do
    new_square1 = square1 + increment

    case square_has_piece(pieces, new_square1) do
      true -> true
      _ -> is_piece_on_the_way(pieces, new_square1, square2, increment)
    end
  end

  defp pieces_of_color(pieces, color), do: Enum.filter(pieces, &(&1.color == color))

  defp opponent_color(%Position{turn: :white}), do: :black
  defp opponent_color(%Position{}), do: :white
end
