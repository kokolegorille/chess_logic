defmodule ChessLogic.Game do
  @moduledoc false

  alias __MODULE__
  alias ChessLogic.Position

  defstruct(
    current_position: nil,
    history: [],
    status: :started,
    winner: nil,
    result: nil
  )

  def new(), do: %Game{current_position: Position.new()}
  def new(fen), do: %Game{current_position: Position.new(fen)}
  
  def play(
        %Game{current_position: current_pos, history: history, status: status} = game,
        move
      ) when status != :over do
    with {:ok, new_current_pos} <- Position.play(current_pos, move), 
      {game_status, turn} <- Position.get_status(new_current_pos)
    do
      {status, winner, result} = case game_status do
        :draw ->
          {:over, nil, "1/2"}
        :checkmate ->
          w = opponent_color(turn)
          {:over, w, winner_result(w)}
        _ ->
          # TODO: Detect 3 times repetition here!
          if is_three_times_repetition(game, new_current_pos) do
            {:over, nil, "1/2"}
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

  def draw(%Game{} = game) do
    {
      :ok,
      %{game| 
        status: :over,
        result: "1/2"
      }
    }
  end
  
  def resign(%Game{current_position: current_pos} = game) do
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

  # PRIVATE

  defp new_history_item(position, move), do: %{fen: position.fen, move: move}
  
  defp opponent_color(:white), do: :black
  defp opponent_color(:black), do: :white
  defp opponent_color(_), do: nil
  
  defp winner_result(:white), do: "1-0"
  defp winner_result(:black), do: "0-1"
  defp winner_result(_), do: nil
  
  defp is_three_times_repetition(%Game{history: history}, %Position{fen: fen}) do
    short_fen = shorten_fen(fen)
    
    list = history 
    |> Enum.map(fn %{fen: f} -> 
      shorten_fen(f)
    end)
    |> Enum.filter(fn el -> el == short_fen end)
    
    (length list) >= 2
  end
  
  defp shorten_fen(fen) do
    fen
    |> String.split()
    |> Enum.take(4) 
    |> Enum.join(" ")
  end
end
