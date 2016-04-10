defmodule BSClient.ServerProcotol do
  def connect({server, nick}) do
    server |> call({:connect, nick})
  end

  def disconnect({server, nick}) do
    server |> call({:disconnect, nick})
  end

  def list_users({server, nick}) do
    server |> cast({:list_users, nick})
  end

  def private_message({server, nick}, to, message) do
    server |> cast({:private_message, nick, to, message})
  end

  def broadcast({server, nick}, message) do
    server |> call({:broadcast, nick, message})
  end

  def request_game({server, nick}, receiver_nick) do
    server |> call({:request_game, nick, receiver_nick})
  end

  defp call(server, args) do
    GenServer.call({:server, server}, args, :infinity)
  end

  defp cast(server, args) do
    GenServer.cast({:server, server}, args)
  end
end
