defmodule ChessLogic.Game do
  @moduledoc false

  alias __MODULE__
  alias ChessLogic.Position

  @draw "1/2-1/2"
  @white_win "1-0"
  @black_win "0-1"

  @type fen() :: String.t()
  @type move() :: String.t()
  @type turn() :: %{
    fen: fen(),
    move: move()
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

  @spec new(fen() | nil) :: t()
  def new(), do: %Game{current_position: Position.new()}
  def new(fen), do: %Game{current_position: Position.new(fen)}
  
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

  # PRIVATE

  defp new_history_item(position, move), do: %{fen: position.fen, move: move}
  
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
