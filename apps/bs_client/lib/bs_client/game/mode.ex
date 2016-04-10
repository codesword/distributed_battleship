defmodule BSClient.Game.Mode do
  alias BSClient.ServerProcotol
  alias BSClient.Game.Message

  def setup do
    IO.puts Message.mode
    IO.gets("Choose any mode to continue: ")
    |> String.rstrip(?\n)
    |> command
  end

  defp command(value) when value in ["h", "human"] do
    opponent_nick = IO.gets("Enter opponent nick: ") |> String.rstrip(?\n)
    ServerProcotol.request_game(opponent_nick)
    |> player(opponent_nick)
  end

  defp command(value) when value in ["c", "computer"] do
    [ opponent: :computer]
  end

  defp command(value, _) do
    IO.puts """
    Command you entered is wrong. Enter a valid command.
    You can enter h, human, c or computer
    """
  end

  defp player(:accepted, nick) do
    IO.puts "You opponent #{nick} accepted to play\n"
    [ opponent: :human, name: nick ]
  end

  defp player(:declined, _nick) do
    IO.puts "Opps!!! Opponent declined the offer to play."
    setup
  end

  defp player(:player_not_online, _) do
    IO.puts "The player with the nick you selected is not online."
    setup
  end
end
