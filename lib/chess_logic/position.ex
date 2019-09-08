defmodule ChessLogic.Position do
  @moduledoc """
  Documentation for Position.
  
  This is the main interface to chessfold functions.
  It is used mainly by Game.
  
  """

  import ChessLogic.CommonTools
  alias __MODULE__
  alias ChessLogic.{Piece, PieceWithSquare}

  @initial_fen_position "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  @san_regex ~r/([BKNPQR])?(([a-h])?([1-8])?)(x)?([a-h])([1-8])(\s*[eE]\.?[pP]\.?\s*)?(=([BNQR]))?([\+#])?/

  @type fen() :: String.t()
  @type color() :: :black | :white
  @type error() :: {:error, term()}

  # Move are in square notation, eg: "e2e4", "g8f6"
  @type move() :: String.t()

  # Reference outside types
  # https://github.com/elixir-lang/elixir/issues/2567
  @type maybe_piece() :: %Piece{} | :empty
  @type position() :: list(list(maybe_piece()))

  @type t() :: %Position{
          fen: fen(),
          position: position()
        }

  defstruct(
    fen: nil,
    position: nil
  )

  @doc ~S"""
  Returns a new position from a fen string.
  Returns default position if fen is not given.
  """
  @spec new(fen() | nil) :: t() | error()
  def new(fen \\ @initial_fen_position)
  def new(fen) when is_nil(fen), do: new(@initial_fen_position)
  def new(fen) when is_binary(fen) do
    with {:chessfold_position, _, _, _, _, _, _} <- fen_to_chessfold_position(fen),
         [position_string, _, _, _, _, _] <- String.split(fen),
         position <- create_position(position_string) do
      %Position{
        fen: fen,
        position: position
      }
    else
      error ->
        {:error, "Could not parse fen #{inspect(error)}"}
    end
  end
  
  @doc ~S"""
  Play a move. a move looks like "e2e4".
  """
  @spec play(t(), move()) :: {:ok, t()} | error()
  def play(%Position{} = position, move) when is_binary(move) do
    case filter_move(position, move) do
      {:chessfold_move, _, _, chessfold_position, _, _} ->
        new_position =
          chessfold_position
          |> :chessfold.position_to_string()
          |> to_string
          |> new()

        {:ok, new_position}

      _ ->
        {:error, "Could not play move #{move}"}
    end
  end

  @doc ~S"""
  Returns a list of all available moves, represented as string.
  """
  @spec all_possible_moves(t()) :: list(move())
  def all_possible_moves(%Position{} = position) do
    position
    |> all_possible_chessfold_moves()
    |> Enum.map(&chessfold_move_to_string(&1))
  end

  @doc ~S"""
  Returns a list of pieces with square from a given position.
  """
  @spec list_pieces_with_square(t()) :: list(term())
  def list_pieces_with_square(%Position{} = position) do
    with {:chessfold_position, pieces, _, _, _, _, _} <- to_chessfold_position(position) do
      pieces
      |> Enum.map(&PieceWithSquare.from_chessfold_piece(&1))
    else
      _ -> []
    end
  end

  @doc ~S"""
  Transforms a short algebraic notation to a move. eg. "Nf3" -> "g1f3".
  """
  @spec san_to_move(t(), String.t()) :: {:ok, String.t()} | error()
  # Clean up san before sending to real implementation
  def san_to_move(%Position{} = position, san) do
    san = sanitize_san(san)
    do_san_to_move(position, san)
  end

  @doc ~S"""
  Transforms a move to a short algebraic notation. eg. "g1f3" -> "Nf3".
  """
  @spec move_to_san(t(), String.t()) :: {:ok, String.t()} | error()
  # https://chess.stackexchange.com/questions/9470/converting-square-notation-to-algebraic-notation-programmatically
  def move_to_san(%Position{} = position, move) do
    # In case of promotion... f7f8=Q"

    {move, promotion_piece} = case move |> String.split("=") do
      [move, pp] -> {move, pp}
      [move] -> {move, "Q"}
    end
    
    case select_chessfold_move(position, move, promotion_piece) do
      [
        {
          :chessfold_move, 
          {:chessfold_piece, _color, from_piece, _sq0x88} = from, 
          {:chessfold_piece, _color, to_piece, to_sq0x88} = to,
          new_pos, 
          castling, 
          taken
        } = _chessfold_move
      ] ->

        to_square = sq0x88_to_square(to_sq0x88)
        
        # calculate params
        is_promotion = from_piece != to_piece
        is_long_castling = castling && to_square.file == 2
        
        is_king_attacked = :chessfold.is_king_attacked(new_pos)
        all_possibles = :chessfold.all_possible_moves(new_pos)
        
        is_checkmate = is_king_attacked && all_possibles == []
        is_stalemate = !is_king_attacked && all_possibles == []

        if castling do
          castling_reply(is_long_castling)
        else
          pawn_symbol = move |> String.graphemes() |> List.first
          piece_symbol = piece_char_from_chessfold_piece(from)
          
          buffer = ""
          |> piece_symbol(from_piece == :pawn, !!taken, pawn_symbol, piece_symbol)
          |> taken_symbol(!!taken)
          |> dest_symbol(String.slice(move, 2, 2))
          |> promotion_symbol(is_promotion, piece_char_from_chessfold_piece(to))
          |> check_symbol(is_checkmate, is_stalemate, is_king_attacked)
          
          {:ok, buffer}
        end
        
      [] ->
        {:error, "Could not transform move #{move} to san"}
    end
  end

  @doc ~S"""
  Returns the tally of the position.
  """
  def get_status(%Position{} = position) do
    chessfold_position = position
    |> to_chessfold_position()
    {:chessfold_position, _, turn, _, _, half_move_clock, _} = chessfold_position
    
    # This cannot detect 3 times repetition's draw
    # But should be delegate to game history
    cond do
      # 50 moves draw
      half_move_clock >= 100 ->
        {:draw, turn}
      (length all_possible_moves(position)) > 0 ->
        {:in_progress, turn}
      :chessfold.is_king_attacked(chessfold_position) ->
        {:checkmate, turn}
      ! :chessfold.is_king_attacked(chessfold_position) ->
        {:draw, turn}
    end
  end

  # PRIVATE

  defp fen_to_chessfold_position(fen) do
    fen
    |> to_charlist
    |> :chessfold.string_to_position()
  end

  defp create_position(position_string) do
    position_string
    |> String.split("/")
    |> Enum.map(&parse_rank(&1))
    # Split string by graphemes
    |> Enum.map(&String.graphemes(&1))
  end

  defp parse_rank(rank) do
    _parse_rank(rank, "")
  end

  defp _parse_rank(<<>>, acc), do: acc

  defp _parse_rank(<<head, tail::binary>>, acc) do
    _parse_rank(tail, acc <> maybe_piece(head))
  end

  defp maybe_piece(piece) when piece in 'prnbqkPRNBQK' do
    [piece]
    |> List.to_string()
  end

  defp maybe_piece(piece) when piece in '12345678' do
    # Pipe to second element
    # http://shulhi.com/piping-to-second-argument-in-elixir/
    # Pipe to second element
    [piece]
    |> List.to_string()
    |> String.to_integer()
    |> (&String.duplicate(" ", &1)).()
  end

  defp to_chessfold_position(%Position{fen: fen}) do
    fen
    |> to_charlist
    |> :chessfold.string_to_position()
  end

  defp chessfold_move_to_string(move) do
    move
    |> :chessfold.move_to_string()
    |> to_string
  end

  defp filter_move(position, move) do
    result =
      position
      |> to_chessfold_position()
      |> :chessfold.all_possible_moves()
      |> Enum.filter(fn m -> chessfold_move_to_string(m) == move end)

    case result do
      [] ->
        nil

      [{:chessfold_move, _, _, _, _, _} = move] ->
        move
    end
  end
  
  defp all_possible_chessfold_moves(position) do
    position
    |> to_chessfold_position()
    |> :chessfold.all_possible_moves()
  end
  
  defp build_san_filter([_san, piece, _prefix, from_file, from_rank, _capture, to_rank, to_file]) do
    # Calculate the from piece (which may differ of to piece, in case of promotion!)
    from_piece = Piece.read_piece_type(piece)
    
    # Calculate the square destination
    square = (to_rank <> to_file)
    |> string_to_square()
    
    # FILTER : Select moves where 
    # * destination match, in sq0x88 format
    # * and the from piece equal from_piece
    fn {
      :chessfold_move, 
      {:chessfold_piece, _color, piece, from_sq0x88} = _from, 
      {:chessfold_piece, _color, _piece, to_sq0x88} = _to, 
      _new_pos, 
      _castling, 
      _taken
    } -> 
      # Transform sq0x88 to square
      to_square = to_sq0x88 |> sq0x88_to_square()
      %{rank: r, file: f} = from_sq0x88 |> sq0x88_to_square()

      # Calculate if needed 
      rank = char_to_rank_or_file(from_rank)
      file = char_to_rank_or_file(from_file)

      # Filter condition
      to_square == square &&
      piece == from_piece &&
      (is_nil(rank) || rank == r) &&
      (is_nil(file) || file == f)
    end
  end
  
  defp piece_char_from_chessfold_piece(chessfold_piece) do
    %PieceWithSquare{piece: p} = PieceWithSquare.from_chessfold_piece(chessfold_piece)
    p |> Piece.show_piece() |> String.upcase
  end
  
  # Given a position, move, promotion_piece...
  # Select the move which fulfill the requirements
  defp select_chessfold_move(position, move, promotion_piece) do
    search = position
    |> all_possible_chessfold_moves()
    |> Enum.filter(fn chessfold_move -> 
      chessfold_move |> chessfold_move_to_string() == move
    end)
    
    if (length search) > 1 do
      search |> Enum.filter(fn {:chessfold_move, _from, to, _new_pos, _castling, _taken} ->
        {:chessfold_piece, _color, to_piece, _sq0x88} = to
        
        Piece.show_piece_type(to_piece) == promotion_piece
      end)
    else
      search
    end
  end
  
  # Real san_to_move implementation
  defp do_san_to_move(%Position{fen: fen}, "O-O") do
    [_, turn, _, _, _, _] = String.split(fen, " ")
    case turn do
      "w" -> {:ok, "e1g1"}
      "b" -> {:ok, "e8g8"}
    end
  end
  defp do_san_to_move(%Position{fen: fen}, "O-O-O") do
    [_, turn, _, _, _, _] = String.split(fen, " ")
    case turn do
      "w" -> {:ok, "e1c1"}
      "b" -> {:ok, "e8c8"}
    end
  end
  defp do_san_to_move(%Position{} = position, san) do
    san = sanitize_san(san)
    
    case Regex.run(@san_regex, san) do
      # extraxt fields from san with regex
      # WARNING! "b1" => file+rank
      
      [_san, _piece, _prefix, _from_file, _from_rank, _capture, _to_rank, _to_file] = splitted_san ->
        filter = build_san_filter(splitted_san)
        
        # Apply filters
        selected_moves = position
        |> all_possible_chessfold_moves()
        |> Enum.filter(&filter.(&1))
        
        case length selected_moves do
          0 -> 
            {:error, "Could not transform san #{san} to move"}
          1 ->
            # One result match!
            move = selected_moves
            |> List.first()
            |> chessfold_move_to_string()
            
            {:ok, move}
          _ -> 
            # Multiple moves available at this point!
            {:error, "Ambiguous san #{san} to move"}
        end
        
      _ ->
        {:error, "Could not transform san #{san} to move"}
    end
  end
  
  # Helpers methods to reduce complexity of move_to_san, san_to_move
  
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
  
  defp sanitize_san(san) do
    san
    |> String.trim()
    |> String.replace("+", "")
    |> String.replace("!", "")
    |> String.replace("?", "")
    |> String.replace_trailing("-", "")
    |> String.replace_trailing("=", "")
  end
end
