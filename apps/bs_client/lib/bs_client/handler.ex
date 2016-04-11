defmodule BSClient.Handler do
  use GenServer

  alias BSClient.Game.Human
  alias BSClient.Game.State
  alias BSClient.Game.Engine

  def start_link(server) do
    GenServer.start_link(__MODULE__, server, name: :client)
  end

  def init(server) do
    { :ok, server }
  end

  def handle_cast({ :message, nick, message }, server) do
    message = message |> String.rstrip
    IO.puts "\n#{server}> #{nick}: #{message}"
    IO.write "#{Node.self}> "
    {:noreply, server}
  end

  def handle_call({:layout_fleet, receiver_nick, { size, count } }, {from, _}, server) do
    State.put(:my_fleet, Human.generate_fleet(size, count))
    {:reply, :ok, server}
  end

  def handle_call({:shoot, receiver_nick, coord }, {from, _}, server) do
    Engine.play_callback(coord, receiver_nick)
  end

  def handle_call({ :request_game, nick }, {from, _}, server) do
    game_requested(server, nick)
  end

  defp game_requested(server, nick) do
    response = IO.gets("#{nick} wants to play a game with you, (a)ccept or (r)eject: ")
                |> String.rstrip(?\n)
    case response do
      "a" ->
        State.start_time
        {:reply, :accepted,  server}
      "accept" ->
        State.start_time
        {:reply, :accepted ,  server}
      "r" -> {:reply, :declined ,  server}
      "rejected" -> {:reply, :decline,  server}
       _ ->
         IO.puts "invalid entry: type a, accept, r or reject to continue."
         game_requested(server, nick)
    end
  end
end
