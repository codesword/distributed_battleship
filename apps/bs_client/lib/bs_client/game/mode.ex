defmodule BSClient.Game.Mode do
  def setup do
    IO.puts Message.mode
    IO.gets("Choose any mode to continue: ")
    |> String.rstrip(?\n)
    |> command
  end

  defp command(value) when value in ["h", "human"] do
    [ opponent: :human ]
  end

  defp command(value) when value in ["c", "computer"] do
    [ opponent: :computer ]
  end

  defp command(value) do
    IO.puts """
    Command you entered is wrong. Enter a valid command.
    You can enter h, human, c or computer
    """
  end
end
