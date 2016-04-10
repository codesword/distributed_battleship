defmodule BSClient do
  use Application

  alias BSClient.Game
  alias BSClient.Handler
  alias BSClient.ServerProcotol
  alias BSClient.Game.State

  def start(_type, _args) do
    get_env
      |> connect
      |> start_handler
    join_game_world
    Game.start
  end

  defp get_env do
    server = System.get_env("server")
      |> String.rstrip
      |> String.to_atom
    nick = System.get_env("nick")
      |> String.rstrip
    {server, nick}
  end

  defp connect({server, nick}) do
    IO.puts "Connecting to #{server} from #{Node.self} ..."
    Node.set_cookie(Node.self, :"distributed-battleship")
    case Node.connect(server) do
      true -> :ok
      reason ->
        IO.puts "Could not connect to game server, reason: #{reason}"
        System.halt(0)
    end
    {server, nick}
  end

  defp start_handler({server, nick}) do
    Handler.start_link(server)
    IO.puts "Connected"
    State.start
    State.put(:server_nick, {server, nick})
  end

  defp join_game_world do
    case ServerProcotol.connect do
      {:ok, users} ->
        IO.puts "* Joined the game world *"
        IO.puts "* Players in the world: #{users} *"
        IO.puts "* Type /help for options *"
      reason ->
        IO.puts "Could not join game world, reason: #{reason}"
        System.halt(0)
    end
  end
end
