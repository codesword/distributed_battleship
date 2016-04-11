defmodule BSClient.Game do
  alias BSClient.ServerProcotol
  alias BSClient.Game.Level
  alias BSClient.Game.Mode
  alias BSClient.Game.Engine
  alias BSClient.Game.Message

  def start do
    IO.write "#{Node.self}> "
    line = IO.read(:line)
      |> String.rstrip
    handle_command line
    start
  end

  def handle_command("/help") do
    IO.puts """
    Available commands:
      /leave                    # Leave the game world. You can still play with computer
      /join                     # Join the game world. You can play with other online players once you join.
      /players                  # View the list of all players online
      /players available        # View the list of all users who are online and ready to play a new game with you.
      /play                     # Start playing the battleship game.
      /instructions             # View the instructions on how to play
      /broadcast                # broadcast message to all players online
      /pm <to nick> <message>   # Send a private message to any player
      /broadcast <message>      # Broadcast message to all players online.
      /quit                     # Quit the game
    """
  end

  def handle_command("/leave") do
    ServerProcotol.disconnect
    IO.puts "You have exited the game world, you can rejoin with /join or quit with /quit"
  end

  def handle_command("/quit") do
    ServerProcotol.disconnect
    IO.puts "Goodbye!!!!"
    System.halt(0)
  end

  def handle_command("/join") do
    ServerProcotol.connect
    IO.puts "Joined the game world"
  end

  def handle_command("/players available") do
    ServerProcotol.list_users
  end

  def handle_command("/players") do
    ServerProcotol.list_users
  end

  def handle_command("/play") do
    level = Level.setup
    game_mode = Mode.setup
    level ++ game_mode
    |> Engine.setup
    |> Engine.play(:human, game_mode[:name])

    IO.puts "\n* Type /help for options *"
  end

  def handle_command("/instructions") do
    Message.instruction
  end

  def handle_command(""), do: :ok

  def handle_command(nil), do: :ok

  def handle_command(message) do
    cond do
      String.contains?(message, "/pm") ->
        {to, message} = parse_private_recipient(message)
        ServerProcotol.private_message(to, message)
      String.contains?(message, "/broadcast") ->
        message
        |> String.slice(11..-1)
        |> ServerProcotol.broadcast
      true ->
        IO.puts "Command not recognised"
    end
  end

  defp parse_private_recipient(message) do
    [to|message] = message
      |> String.slice(4..-1)
      |> String.split
    message = message
      |> List.foldl("", fn(x, acc) -> "#{acc} #{x}" end)
      |> String.lstrip
    {to, message}
  end
end
