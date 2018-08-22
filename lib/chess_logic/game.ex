defmodule ChessLogic.Game do
  @moduledoc """
  Documentation for Game.
  
  The main entity, 
  
  April 2018, klg
  """

  alias __MODULE__
  alias ChessLogic.Position

  @draw "1/2-1/2"
  @white_win "1-0"
  @black_win "0-1"

  @type fen() :: String.t()
  @type move() :: String.t()
  @type san() :: String.t()
  @type turn() :: %{
    fen: fen(),
    move: move(),
    san: san()
  }
  @type error() :: {:error, term()}
  @type t() :: %Game{
    current_position: %Position{},
    history: list(turn()),
    status: atom(),
    winner: String.t(),
    result: String.t()
  }
  
  defstruct(
    current_position: nil,
    history: [],
    status: :started,
    winner: nil,
    result: nil
  )

  @doc ~S"""
  Returns a new game.
  
  ## Examples
  
      iex> alias ChessLogic
      iex> game = Game.new()
      iex> {:ok, game} = game |> Game.play("e2e4")
      iex> {:ok, game} = game |> Game.play("c7c5")
      iex> game.current_position.fen
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  
  """
  @spec new(fen()) :: t() | error()
  def new(), do: new(nil)
  def new(fen) do 
    case Position.new(fen) do
      %Position{} = position ->
        %Game{current_position: position}
      {:error, reason} -> 
        {:error, reason}
    end
  end
  
  @doc ~S"""
  Play a move. a move looks like "e2e4".
  """
  @spec play(t(), move()) :: {:ok, t()} | error()
  def play(
        %Game{
          current_position: current_pos, history: history, status: status
        } = game,
        move
      ) when status != :over do
    with {:ok, new_current_pos} <- Position.play(current_pos, move), 
      {game_status, turn} <- Position.get_status(new_current_pos)
    do
      {status, winner, result} = case game_status do
        :draw ->
          {:over, nil, @draw}
        :checkmate ->
          w = opponent_color(turn)
          {:over, w, winner_result(w)}
        _ ->
          if is_three_times_repetition(game, new_current_pos) do
            {:over, nil, @draw}
          else
            {:playing, nil, nil}
          end
      end
      {
        :ok,
        %{game| 
          current_position: new_current_pos,
          history: [new_history_item(current_pos, move) | history],
          status: status,
          winner: winner,
          result: result
        }
      }

    else
      {:error, reason} ->
        {:error, reason}
    end
  end
  def play(_game, move), do: {:error, "Could not play move #{move}"}

  @doc ~S"""
  Set the result to draw.
  """
  @spec draw(t()) :: {:ok, t()} | error()
  def draw(%Game{status: status} = game) when status != :over do
    {
      :ok,
      %{game| 
        status: :over,
        result: @draw
      }
    }
  end
  def draw(_game), do: {:error, "Could not draw game"}

  @doc ~S"""
  Resign a game.
  """
  @spec resign(t()) :: {:ok, t()} | error()
  def resign(%Game{current_position: current_pos, status: status} = game)
    when status != :over 
  do
    {_, turn} = Position.get_status(current_pos)
    w = opponent_color(turn)
    {
      :ok,
      %{game| 
        status: :over,
        winner: w,
        result: winner_result(w)
      }
    }
  end
  def resign(_game), do: {:error, "Could not resign game"}

  @doc ~S"""
  Set result of the game.
  """
  @spec set_result(t(), String.t()) :: {:ok, t()} | error()
  def set_result(%Game{status: status} = game, "1-0" = result) when status != :over do
    {:ok, %{game | status: :over, winner: :white, result: result}}
  end
  def set_result(%Game{status: status} = game, "0-1" = result) when status != :over do
    {:ok, %{game | status: :over, winner: :white, result: result}}
  end
  def set_result(%Game{status: status} = game, "1/2-1/2" = result) when status != :over do
    {:ok, %{game | status: :over, result: result}}
  end
  def set_result(_game, result)  do
    {:error, "Could not set result #{result}"}
  end

  # @doc ~S"""
  # Export the move list history to pgn string.
  # """
  # @spec to_pgn(t()) :: String.t()
  # def to_pgn(%Game{history: history}) do
  #   history
  #   |> Enum.reverse
  #   |> Enum.map(& &1.san)
  #   |> Enum.with_index()
  #   |> Enum.chunk_every(2)
  #   |> Enum.map(fn list ->
  #     case list do
  #       # The last move is from white
  #       [{san1, index1}] ->
  #         "#{round((index1 + 2) / 2)}. #{san1}"
  #       # A list with white/black move
  #       [{san1, index1}, {san2, _index2}] ->
  #         "#{round((index1 + 2) / 2)}. #{san1} #{san2}"
  #     end
  #   end)
  #   |> Enum.join(" ")
  # end
  
  # @doc ~S"""
  # Import pgn into a game.
  # """
  # @spec from_pgn(String.t()) :: t()
  # def from_pgn(pgn) do
  #   {:ok, tokens, _} = pgn
  #   |> String.trim("\uFEFF")
  #   |> to_charlist
  #   |> :pgn_lexer.string()
  #
  #   {:ok, syntax_tree} = tokens |> :pgn_parser.parse()
  #
  #   syntax_tree
  #   |> Enum.map(fn {:tree, _tags, elems} ->
  #
  #     elems
  #     |> Enum.filter(fn elem ->
  #       case elem do
  #         {type, _, _} -> type == :san
  #         # Variation are tuple with 2 elements
  #         {_, _} -> false
  #       end
  #     end)
  #     |> Enum.reduce(Game.new(), fn {:san, _, san}, g ->
  #
  #       case Position.san_to_move(g.current_position, to_string(san)) do
  #         {:ok, m} ->
  #           {:ok, g} = Game.play(g, m)
  #           g
  #         {:error, reason} ->
  #           IO.puts "Could not process game tokens #{reason} for #{inspect g}"
  #           g
  #       end
  #
  #     end)
  #
  #   end)
  # end
    
  # PRIVATE

  defp new_history_item(%Position{fen: fen} = position, move) do
    {:ok, san} = ChessLogic.Position.move_to_san(position, move)
    %{fen: fen, move: move, san: san}
  end
  
  defp opponent_color(:white), do: :black
  defp opponent_color(:black), do: :white
  defp opponent_color(_), do: nil
  
  defp winner_result(:white), do: @white_win
  defp winner_result(:black), do: @black_win
  defp winner_result(_), do: nil
  
  # Check if the position repeats 3x
  defp is_three_times_repetition(%Game{history: history}, %Position{fen: fen}) do
    short_fen = shorten_fen(fen)
    
    list = history 
    |> Enum.map(fn %{fen: f} -> 
      shorten_fen(f)
    end)
    |> Enum.filter(fn el -> el == short_fen end)
    
    (length list) >= 2
  end
  
  # Drop the last 2 fields from fen: half_move and full_move
  defp shorten_fen(fen) do
    fen
    |> String.split()
    |> Enum.take(4) 
    |> Enum.join(" ")
  end
end
