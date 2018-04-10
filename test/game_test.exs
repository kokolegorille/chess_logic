defmodule GameTest do
  use ExUnit.Case

  alias ChessLogic.Game

  test "can create game" do
    assert %Game{} = Game.new()
  end
  
  test "can play moves" do
    g = Game.new()
    assert {:ok, g} = Game.play(g, "e2e4")
    assert {:ok, _g} = Game.play(g, "c7c5")
  end
  
  test "cannot play invalid move" do
    g = Game.new()
    assert {:error, _} = Game.play(g, "c7c5")
  end
  
  test "cannot play a game over" do
    g = Game.new()
    assert {:ok, g} = Game.resign(g)
    assert {:error, _reason} = Game.play(g, "e2e4")
  end
  
  test "can checkmate meli" do
    g = Game.new()
    assert {:ok, g} = Game.play(g, "f2f3")
    assert {:ok, g} = Game.play(g, "e7e5")
    assert {:ok, g} = Game.play(g, "g2g4")
    assert {:ok, g} = Game.play(g, "d8h4")
    assert g.status == :over
    assert g.winner == :black
    assert g.result == "0-1"
  end
  
  test "can draw a game" do
    g = Game.new()
    assert {:ok, g} = Game.draw(g)
    assert g.status == :over
    assert g.winner == nil
    assert g.result == "1/2-1/2"
  end
  
  test "cannot draw a game over" do
    g = Game.new()
    assert {:ok, g} = Game.resign(g)
    assert {:error, _reason} = Game.draw(g)
  end
  
  test "can resign a game" do
    g = Game.new()
    assert {:ok, g} = Game.resign(g)
    assert g.status == :over
    assert g.winner == :black
    assert g.result == "0-1"
  end
  
  test "cannot resign a game over" do
    g = Game.new()
    assert {:ok, g} = Game.resign(g)
    assert {:error, _reason} = Game.resign(g)
  end
  
  test "can draw a game after 3x" do
    g = Game.new()
    assert {:ok, g} = Game.play(g, "g1f3")
    assert {:ok, g} = Game.play(g, "b8c6")
    assert {:ok, g} = Game.play(g, "f3g1")
    assert {:ok, g} = Game.play(g, "c6b8")
    assert {:ok, g} = Game.play(g, "g1f3")
    assert {:ok, g} = Game.play(g, "b8c6")
    assert {:ok, g} = Game.play(g, "f3g1")
    assert {:ok, g} = Game.play(g, "c6b8") # -> 3x start position!
    
    assert g.status == :over
    assert g.winner == nil
    assert g.result == "1/2-1/2"
  end
  
  test "can draw after 50 moves" do
    # Set half move to 99
    g = Game.new("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 99 100")
    assert {:ok, g} = Game.play(g, "g1f3")
    assert {:error, _reason} = Game.play(g, "b8c6")
    
    # Set half move to 99
    g = Game.new("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 99 100")
    assert {:ok, g} = Game.play(g, "e2e4")
    assert {:ok, _g} = Game.play(g, "b8c6")
  end
end