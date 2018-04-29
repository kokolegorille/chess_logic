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
  
  test "can load data from sample pgn" do
    filename = "./test/fixtures/sample.pgn"    
    assert File.exists? filename
    
    {:ok, pgn} = File.read(filename)
    games = Game.from_pgn(pgn)
    g = games |> List.first
    
    assert Game.to_pgn(g) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8 10. d4 Nd7 11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4 15. Nb1 h6 16. Bh4 c5 17. dxe5 Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nd2 Nxd6 21. Nc4 Nxc4 22. Bxc4 Nb6 23. Ne5 Re8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+ 26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5 hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4 32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5 35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4 38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6 Nf2 42. g4 Bd3 43. Re6"
  end
  
  test "can load data from complex pgn" do
    filename = "./test/fixtures/complex.pgn"    
    assert File.exists? filename
    
    {:ok, pgn} = File.read(filename)
    games = Game.from_pgn(pgn)
    g = games |> List.first
    
    assert Game.to_pgn(g) == "1. e4 c5 2. Nf3 e6 3. d4 cxd4 4. Nxd4 Nc6 5. Nc3 a6 6. Be2 Qc7 7. O-O Nf6 8. Be3 Bb4 9. Na4 O-O 10. c4 Bd6 11. g3 Nxe4 12. Bf3 f5 13. Bxe4 fxe4 14. c5 Be7 15. Qg4 Ne5 16. Qxe4 d5 17. cxd6 Bxd6 18. Rc1 Qa5 19. Nb3 Qb4 20. Qxb4 Bxb4 21. Nb6 Rb8 22. Bc5 Bxc5 23. Nxc5 Rd8 24. Rd1 Re8 25. Ne4 Nf7 26. Rc7 Kf8 27. Rc1"
  end
  
  test "can dump data to pgn" do
    g = Game.new()
    assert {:ok, g} = Game.play(g, "d2d4")
    assert {:ok, g} = Game.play(g, "d7d5")
    assert {:ok, g} = Game.play(g, "c2c4")
    assert {:ok, g} = Game.play(g, "e7e6")
    assert {:ok, g} = Game.play(g, "b1c3")
    assert {:ok, g} = Game.play(g, "g8f6")
    assert {:ok, g} = Game.play(g, "c4d5")
    assert {:ok, g} = Game.play(g, "e6d5")
    
    assert Game.to_pgn(g) == "1. d4 d5 2. c4 e6 3. Nc3 Nf6 4. cxd5 exd5"
  end
  
  test "can set result" do
    g = Game.new()
    assert {:ok, _g} = Game.set_result(g, "1-0")
    assert {:ok, _g} = Game.set_result(g, "0-1")
    assert {:ok, _g} = Game.set_result(g, "1/2-1/2")
    assert {:error, _} = Game.set_result(g, "1-1")
    
    assert {:ok, g} = Game.set_result(g, "1-0")
    assert g.status == :over
    assert g.winner == :white
    assert g.result == "1-0"
  end
end