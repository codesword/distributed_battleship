defmodule BSClient.Game.Mode do
  alias BSClient.ServerProcotol

  def setup(args) do
    IO.puts Message.mode
    IO.gets("Choose any mode to continue: ")
    |> String.rstrip(?\n)
    |> command(args)
  end

  defp command(value, args) when value in ["h", "human"] do
    nick = IO.gets("Enter opponent nick: ") |> String.rstrip(?\n)
    ServerProcotol.request_game(args)
    |> player(nick)
  end

  defp command(value, args) when value in ["c", "computer"] do
    [ opponent: :computer ]
  end

  defp command(value, args) do
    IO.puts """
    Command you entered is wrong. Enter a valid command.
    You can enter h, human, c or computer
    """
  end

  defp player(:accepted, nick) do
    [ opponent: :human, name: nick ]
  end

  defp player(:declined, _nick) do
    IO.puts "Opponent declined the offer to play."
    setup
  end

  defp player(:player_not_online, _nick) do
    IO.puts "The player with the nick you selected is not online."
    setup
  end
end
