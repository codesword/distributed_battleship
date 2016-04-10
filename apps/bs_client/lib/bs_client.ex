defmodule BSClient do
  use Application

  alias BSClient.ServerProcotol
  alias BSClient.Handler
  alias BSClient.Engine

  def start(_type, _args) do
    get_env
      |> connect
      |> start_handler
      |> join_game_world
      |> Engine.input_loop
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
    Node.set_cookie(Node.self, :"battleship")
    case Node.connect(server) do
      true -> :ok
      reason ->
        IO.puts "Could not connect to game server, reason: #{reason}"
        System.halt(0)
    end
    {server, nick}
  end

  defp start_handler({server, nick}) do
    BSClient.Handler.start_link(server)
    IO.puts "Connected"
    {server, nick}
  end

  defp join_game_world({server, nick}) do
    case ServerProcotol.connect({server, nick}) do
      {:ok, users} ->
        IO.puts "* Joined the game world *"
        IO.puts "* Users in the room: #{users} *"
        IO.puts "* Type /help for options *"
      reason ->
        IO.puts "Could not join game world, reason: #{reason}"
        System.halt(0)
    end
    {server, nick}
  end
end