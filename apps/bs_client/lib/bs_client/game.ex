defmodule BSClient.Game do
  alias BSClient.ServerProcotol

  def start({server, nick}) do
    IO.write "#{Node.self}> "
    line = IO.read(:line)
      |> String.rstrip
    handle_command line, {server, nick}
    start {server, nick}
  end

  def handle_command("/help", _args) do
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
    """
  end

  def handle_command("/leave", args) do
    ServerProcotol.disconnect(args)
    IO.puts "You have exited the game world, you can rejoin with /join or quit with /quit"
  end

  def handle_command("/quit", args) do
    ServerProcotol.disconnect(args)
    IO.puts "Goodbye!!!!"
    System.halt(0)
  end

  def handle_command("/join", args) do
    ServerProcotol.connect(args)
    IO.puts "Joined the game world"
  end

  def handle_command("/players available", args) do
    ServerProcotol.list_users(args)
  end

  def handle_command("/players", args) do
    ServerProcotol.list_users(args)
  end

  def handle_command("/play", args) do
    ServerProcotol.list_users(args)
  end

  def handle_command("/instructions", args) do
    ServerProcotol.list_users(args)
  end

  def handle_command("/broadcast", args) do
    ServerProcotol.list_users(args)
  end

  def handle_command("", _args), do: :ok

  def handle_command(nil, _args), do: :ok

  def handle_command(message, args) do
    if String.contains?(message, "/pm") do
      {to, message} = parse_private_recipient(message)
      ServerProcotol.private_message(args, to, message)
    else
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
