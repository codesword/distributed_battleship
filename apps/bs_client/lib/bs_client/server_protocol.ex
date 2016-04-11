defmodule BSClient.ServerProcotol do
  alias BSClient.Game.State
  def connect do
    call {:connect}
  end

  def disconnect do
    call {:disconnect}
  end

  def list_users do
    cast {:list_users}
  end

  def private_message(to, message) do
    cast {:private_message, to, message}
  end

  def broadcast(message) do
    cast {:broadcast, message}
  end

  def request_game(receiver_nick) do
    call {:request_game, receiver_nick}
  end

  def shoot(coord, receiver_nick) do
    call {:shoot, receiver_nick, coord}
  end

  def layout_fleet(receiver_nick, args) do
    IO.puts "\n #{receiver_nick} is laying out his ship. Please wait!!!\n"
    call {:layout_fleet, receiver_nick, args}
  end

  defp call(args) do
    { server, nick } = State.get(:server_nick)
    args = Tuple.insert_at(args, 1, nick)
    GenServer.call({:server, server}, args, :infinity)
  end

  defp cast(args) do
    { server, nick } = State.get(:server_nick)
    args = Tuple.insert_at(args, 1, nick)
    GenServer.cast({:server, server}, args)
  end
end
