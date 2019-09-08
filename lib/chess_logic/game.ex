defmodule ChessLogic.Game do
  @moduledoc """
  Documentation for Game.

  The main entity,

  April 2018, klg
  September 2019, v0.3.0
  """

  require Logger
  alias __MODULE__
  alias ChessLogic.{Position, Move}

  @draw "1/2-1/2"
  @white_win "1-0"
  @black_win "0-1"

  defstruct(
    current_position: nil,
    history: [],
    status: :started,
    winner: nil,
    result: nil
  )

  @doc ~S"""
  Returns a new game from initial position fen.
  It is possible to pass a fen as Game initializer.
  """
  def new(), do: %Game{current_position: Position.from_fen()}
  def new(fen), do: %Game{current_position: Position.from_fen(fen)}

  @doc ~S"""
  Plays a move.
  """
  def play(%Game{status: :over}, _move), do: {:error, "Game is over"}

  def play(%Game{current_position: current_position, history: history} = game, move) do
    case Position.play(current_position, move) do
      {:ok, position} ->
        previous_fen = Position.to_fen(current_position)
        current_fen = Position.to_fen(position)

        new_history = [
          new_history_item(previous_fen, move_to_san(current_position, move)) | history
        ]

        game_update =
          case Position.status(position) do
            :in_progress ->
              Map.merge(
                %{history: new_history},
                is_three_times_repetition_result(history, current_fen)
              )

            :draw ->
              %{history: new_history, result: @draw, status: :over}

            :checkmate ->
              {winner, result} = checkmate_result(position.turn)
              %{history: new_history, status: :over, winner: winner, result: result}
          end

        new_game = Map.merge(%{game | current_position: position}, game_update)
        {:ok, new_game}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp is_three_times_repetition_result(history, fen) do
    if is_three_times_repetition(history, fen) do
      %{status: :over, result: @draw}
    else
      %{}
    end
  end

  defp checkmate_result(turn) do
    if turn == :white,
      do: {:black, @black_win},
      else: {:white, @white_win}
  end

  defp new_history_item(fen, san), do: %{fen: fen, san: san}

  defp move_to_san(%Position{} = position, move) do
    moves = Position.all_possible_moves(position)

    case Move.move_to_san(moves, move) do
      {:ok, move} -> move
      {:error, reason} -> raise("Could not retrieve san move for #{move}, #{reason}")
    end
  end

  # Check if the position repeats 3x
  defp is_three_times_repetition(history, fen) do
    short_fen = shorten_fen(fen)

    list =
      history
      |> Enum.map(fn %{fen: f} -> shorten_fen(f) end)
      |> Enum.filter(fn el -> el == short_fen end)

    length(list) >= 2
  end

  # Drop the last 2 fields from fen: half_move and full_move
  defp shorten_fen(fen) do
    fen
    |> String.split()
    |> Enum.take(4)
    |> Enum.join(" ")
  end

  @doc ~S"""
  Set the result to draw.
  """
  def draw(%Game{status: :over}), do: {:error, "Game is over"}

  def draw(%Game{} = game) do
    {:ok, %{game | status: :over, result: @draw}}
  end

  @doc ~S"""
  Resign a game.
  """
  def resign(%Game{status: :over}), do: {:error, "Game is over"}

  def resign(%Game{current_position: current_position} = game) do
    case current_position.turn do
      :white -> {:ok, %{game | status: :over, winner: :black, result: @black_win}}
      :black -> {:ok, %{game | status: :over, winner: :white, result: @white_win}}
    end
  end

  @doc ~S"""
  Set result of the game.
  """
  def set_result(%Game{status: :over}, _result), do: {:error, "Game is over"}

  def set_result(%Game{} = game, "1-0" = result),
    do: {:ok, %{game | status: :over, winner: :white, result: result}}

  def set_result(%Game{} = game, "0-1" = result),
    do: {:ok, %{game | status: :over, winner: :black, result: result}}

  def set_result(%Game{} = game, "1/2-1/2" = result),
    do: {:ok, %{game | status: :over, result: result}}

  def set_result(_game, result), do: {:error, "Could not set result #{result}"}

  @doc ~S"""
  Export the history move list to pgn string.
  """
  def to_pgn(%Game{history: history}) do
    history
    |> Enum.reverse()
    |> Enum.map(& &1.san)
    |> Enum.with_index()
    |> Enum.chunk_every(2)
    |> Enum.map(fn list ->
      case list do
        # The last move is from white
        [{san1, index1}] ->
          "#{round((index1 + 2) / 2)}. #{san1}"

        # A list with white/black move
        [{san1, index1}, {san2, _index2}] ->
          "#{round((index1 + 2) / 2)}. #{san1} #{san2}"
      end
    end)
    |> Enum.join(" ")
  end

  @doc ~S"""
  Import game from pgn string.

  Returns a list of games, as pgn could contain multiple trees

  The string MUST BE utf8!
  Otherwise, add :iconv and use
  new_string = :iconv.convert "utf-8", "ascii//translit", string

  Example : Chess.from_pgn "[White \"Calistri, Tristan\"]\n[Black \"Bauduin, Etienne\"]\n 1. e4 c5"
  """
  def from_pgn(pgn) do
    if String.valid?(pgn) do
      pgn_charlist =
        pgn
        # trim bom character
        |> String.trim("\uFEFF")
        |> to_charlist

      with {:ok, tokens, _} <- :pgn_lexer.string(pgn_charlist),
           {:ok, syntax_tree} <- :pgn_parser.parse(tokens) do
        syntax_tree
        |> Enum.map(fn {:tree, _tags, elems} ->
          moves =
            elems
            |> Enum.filter(fn elem ->
              case elem do
                {type, _, _} -> type == :san
                # Variation are tuple with 2 elements
                {_, _} -> false
              end
            end)

          moves
          |> Enum.reduce(new(), fn {:san, _, san}, game ->
            # san are charlist here!
            case play(game, to_string(san)) do
              {:ok, game} ->
                game

              {:error, reason} ->
                Logger.error("Could not play game move #{reason} for #{inspect(game)}")
                game
            end
          end)
        end)
      else
        {:error, _, _} -> {:error, "PGN lexer failed."}
        {:error, reason} -> {:error, "PGN parser failed with #{inspect(reason)}."}
      end
    else
      {:error, "PGN is not a valid string."}
    end
  end

  @doc ~S"""
  Import game from pgn file.
  """
  def from_pgn_file(file) do
    file
    |> File.read!()
    |> from_pgn()
  end

  @doc ~S"""
  Prints a game current position.
  """
  def print(game), do: Position.print(game.current_position)
end
