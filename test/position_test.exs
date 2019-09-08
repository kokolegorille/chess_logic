defmodule PositionTest do
  use ExUnit.Case

  alias ChessLogic.Position

  test "can create position" do
    assert %Position{} = Position.new()
  end
  
  test "can play move" do
    p = Position.new()
    assert {:ok, p} = Position.play(p, "e2e4")
    assert {:ok, _p} = Position.play(p, "c7c5")
  end
  
  # SAN -> MOVE
  
  test "can translate san to move" do
    p = Position.new()
    assert Position.san_to_move(p, "e4") == {:ok, "e2e4"}
    assert Position.san_to_move(p, "Nf3") == {:ok, "g1f3"}
  end
  
  test "cannot translate ambiguous san" do
    p = Position.new()
    assert {:ok, p} = Position.play(p, "g1f3")
    assert {:ok, p} = Position.play(p, "b8c6")
    assert {:ok, p} = Position.play(p, "d2d3")
    assert {:ok, p} = Position.play(p, "e7e6")
    
    assert Position.san_to_move(p, "Nd2") == {:error, "Ambiguous san Nd2 to move"}
    assert Position.san_to_move(p, "Nbd2") == {:ok, "b1d2"}
    assert Position.san_to_move(p, "N1d2") == {:ok, "b1d2"}
    assert Position.san_to_move(p, "Nfd2") == {:ok, "f3d2"}
    assert Position.san_to_move(p, "N3d2") == {:ok, "f3d2"}
    assert Position.san_to_move(p, "Nf3d2") == {:ok, "f3d2"}
  end
  
  test "can translate san castle" do
    p = Position.new()
    assert {:ok, p} = Position.play(p, "e2e4")
    assert {:ok, p} = Position.play(p, "e7e5")
    assert {:ok, p} = Position.play(p, "g1f3")
    assert {:ok, p} = Position.play(p, "b8c6")
    assert {:ok, p} = Position.play(p, "f1c4")
    assert {:ok, p} = Position.play(p, "f8c5")
    
    assert {:ok, p} = Position.play(p, "b1c3")
    assert {:ok, p} = Position.play(p, "g8f6")
    assert {:ok, p} = Position.play(p, "d2d3")
    assert {:ok, p} = Position.play(p, "d7d6")
    assert {:ok, p} = Position.play(p, "c1g5")
    assert {:ok, p} = Position.play(p, "c8g4")
    assert {:ok, p} = Position.play(p, "d1d2")
    assert {:ok, p} = Position.play(p, "d8d7")
    
    assert Position.san_to_move(p, "O-O") == {:ok, "e1g1"}
    assert Position.san_to_move(p, "O-O-O") == {:ok, "e1c1"}
    
    assert {:ok, p} = Position.play(p, "e1c1")
    assert Position.san_to_move(p, "O-O") == {:ok, "e8g8"}
    assert Position.san_to_move(p, "O-O-O") == {:ok, "e8c8"}
  end
  
  # MOVE -> SAN
  
  test "can translate move san" do
    p = Position.new()
    assert Position.move_to_san(p, "e2e4") == {:ok, "e4"}
    assert Position.move_to_san(p, "g1f3") == {:ok, "Nf3"}
  end
  
  test "can translate capture" do
    p = Position.new()
    assert {:ok, p} = Position.play(p, "e2e4")
    assert {:ok, p} = Position.play(p, "f7f5")
    assert Position.move_to_san(p, "e4f5") == {:ok, "exf5"}
  end
  
  test "can translate check" do
    p = Position.new()
    assert {:ok, p} = Position.play(p, "e2e4")
    assert {:ok, p} = Position.play(p, "f7f5")
    assert Position.move_to_san(p, "d1h5") == {:ok, "Qh5+"}
  end
  
  test "can translate checkmate" do
    p = Position.new()
    assert {:ok, p} = Position.play(p, "f2f3")
    assert {:ok, p} = Position.play(p, "e7e5")
    assert {:ok, p} = Position.play(p, "g2g4")
    
    assert Position.move_to_san(p, "d8h4") == {:ok, "Qh4#"}
  end
  
  test "can translate castle" do
    p = Position.new()
    assert {:ok, p} = Position.play(p, "e2e4")
    assert {:ok, p} = Position.play(p, "e7e5")
    assert {:ok, p} = Position.play(p, "g1f3")
    assert {:ok, p} = Position.play(p, "b8c6")
    assert {:ok, p} = Position.play(p, "f1b5")
    assert {:ok, p} = Position.play(p, "g8f6")
    
    assert Position.move_to_san(p, "e1g1") == {:ok, "O-O"}
  end
  
  test "can translate long castle" do
    p = Position.new()
    assert {:ok, p} = Position.play(p, "d2d4")
    assert {:ok, p} = Position.play(p, "e7e5")
    assert {:ok, p} = Position.play(p, "b1c3")
    assert {:ok, p} = Position.play(p, "b8c6")
    assert {:ok, p} = Position.play(p, "c1g5")
    assert {:ok, p} = Position.play(p, "g8f6")
    assert {:ok, p} = Position.play(p, "d1d2")
    assert {:ok, p} = Position.play(p, "f8e7")
    
    assert Position.move_to_san(p, "e1c1") == {:ok, "O-O-O"}
  end
  
  # Check if ep is needed!
  test "can translate en passant" do
    p = Position.new()
    assert {:ok, p} = Position.play(p, "e2e4")
    assert {:ok, p} = Position.play(p, "d7d5")
    assert {:ok, p} = Position.play(p, "e4e5")
    assert {:ok, p} = Position.play(p, "f7f5")
    
    assert Position.move_to_san(p, "e5f6") == {:ok, "exf6"}
  end
  
  test "can translate promotion" do
    p = Position.new()
    assert {:ok, p} = Position.play(p, "e2e4")
    assert {:ok, p} = Position.play(p, "f7f5")
    assert {:ok, p} = Position.play(p, "e4f5")
    assert {:ok, p} = Position.play(p, "g7g6")
    
    assert {:ok, p} = Position.play(p, "f5g6")
    assert {:ok, p} = Position.play(p, "f8g7")
    assert {:ok, p} = Position.play(p, "g6h7")
    assert {:ok, p} = Position.play(p, "b8c6")
    
    assert Position.move_to_san(p, "h7g8") == {:ok, "hxg8=Q+"}
    assert Position.move_to_san(p, "h7g8=B") == {:ok, "hxg8=B"}
    assert Position.move_to_san(p, "h7g8=N") == {:ok, "hxg8=N"}
    assert Position.move_to_san(p, "h7g8=R") == {:ok, "hxg8=R+"}
    
    assert Position.move_to_san(p, "h7g8=p") == {:error, "Could not transform move h7g8 to san"}
    assert Position.move_to_san(p, "h7g8=K") == {:error, "Could not transform move h7g8 to san"}
  end
end