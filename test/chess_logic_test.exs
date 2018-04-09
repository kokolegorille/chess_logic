defmodule ChessLogicTest do
  use ExUnit.Case
  doctest ChessLogic

  test "greets the world" do
    assert ChessLogic.hello() == :world
  end
end
