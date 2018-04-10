defmodule ChessLogic.Position do
  @moduledoc false

  alias __MODULE__
  alias ChessLogic.{Piece, PieceWithSquare}

  @initial_fen_position "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

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

  @spec new(fen() | nil) :: t() | error()
  def new(fen \\ @initial_fen_position) when is_binary(fen) do
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

  @spec all_possible_moves(t()) :: list(move())
  def all_possible_moves(%Position{} = position) do
    position
    |> to_chessfold_position()
    |> :chessfold.all_possible_moves()
    |> Enum.map(&chessfold_move_to_string(&1))
  end

  @spec list_pieces_with_square(t()) :: list(term())
  def list_pieces_with_square(%Position{} = position) do
    with {:chessfold_position, pieces, _, _, _, _, _} <- to_chessfold_position(position) do
      pieces
      |> Enum.map(&PieceWithSquare.from_chessfold_piece(&1))
    else
      _ -> []
    end
  end

  # @spec tally(t()) :: map()
  # def tally(%Position{} = position) do
  #   position
  # end
  
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
    # Split string by graphemes
    position_string
    |> String.split("/")
    |> Enum.map(&parse_rank(&1))
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
end
