defmodule BSClient.Game.Level do
  alias BSClient.Game.Message

  def setup do
    IO.puts Message.level
    IO.gets("Choose any level to continue: ")
    |> String.rstrip(?\n)
    |> command
  end

  defp command(value) when value in ["b", "beginner"] do
    [board_size: 4, ship_count: 2]
  end

  defp command(value) when value in ["i", "intermidiate"] do
    [board_size: 8, ship_count: 3]
  end

  defp command(value) when value in ["a", "advance"] do
    [board_size: 12, ship_count: 4]
  end
end
