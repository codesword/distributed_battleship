defmodule BSServer.Worker do
  use GenServer
  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    { :ok, HashDict.new }
  end

  def handle_call({ :connect, nick }, {from, _} , users) do
    cond do
      nick == :server or nick == "server" ->
        {:reply, :nick_not_allowed, users}
      HashDict.has_key?(users, nick) ->
        {:reply, :nick_in_use, users}
      true ->
        new_users = users |> HashDict.put(nick, node(from))
        user_list = log(new_users, nick, "has joined")
        {:reply, { :ok, user_list }, new_users}
    end
  end

  def handle_call({ :disconnect, nick }, {from, _}, users) do
    user = HashDict.get(users, nick)
    cond do
      user == nil ->
        {:reply, :user_not_found, users}
      user == node(from) ->
        new_users = users |> HashDict.delete(nick)
        log(new_users, nick, "has left")
        {:reply, :ok, new_users }
      true ->
        {:reply, :not_allowed, users }
    end
  end

  def handle_call({:request_game, nick, receiver_nick }, {from, _}, users) do
    case HashDict.get(users, receiver_nick) do
      nil -> { :reply, :player_not_online, users }
      receiver_node ->
        response = call(receiver_node, { :request_game, nick })
        { :reply, response, users }
    end
  end

  def handle_call({:valid_shoot, nick, receiver_nick, coord }, {from, _}, users) do
    case HashDict.get(users, receiver_nick) do
      nil -> { :reply, :player_not_online, users }
      receiver_node ->
        response = call(receiver_node, { :valid_shoot, coord })
        { :reply, response, users }
    end
  end


  def handle_cast({:layout_fleet, nick, receiver_nick, args }, users) do
    case HashDict.get(users, receiver_nick) do
      nil -> :ok
      receiver_node ->
        cast receiver_node, {:layout_fleet, nick, args}
    end
    { :noreply, users }
  end

  def handle_cast({:display_status, nick, receiver_nick, status, ship_size }, users) do
    case HashDict.get(users, receiver_nick) do
      nil -> :ok
      receiver_node ->
        cast receiver_node, {:display_status, nick, status, ship_size}
    end
    { :noreply, users }
  end

  def handle_cast({:shoot, nick, receiver_nick, coord }, users) do
    case HashDict.get(users, receiver_nick) do
      nil -> :ok
      receiver_node ->
        coord = cast receiver_node, {:shoot, nick, coord}
    end
    { :noreply, users }
  end

  def handle_cast({ :private_message, nick, receiver_nick, message }, users) do
    case HashDict.get(users, receiver_nick) do
      nil -> :ok
      receiver_node ->
        cast receiver_node, { :message, nick, message }
    end
    {:noreply, users}
  end

  def handle_cast({ :broadcast, nick, message }, users) do
    ears = HashDict.delete(users, nick)
    Logger.debug("#{nick} said #{message}")
    broadcast(ears, nick, message)
    {:noreply, users}
  end

  def handle_cast({ :list_users, nick }, users) do
    user_list = users |> HashDict.keys |> Enum.join(", ")
    GenServer.cast( :server, { :private_message, "server", nick, "users: #{user_list}"})
    {:noreply, users}
  end

  defp log(users, nick, message) do
    user_list = users |> HashDict.keys |> Enum.join(":")
    Logger.debug("#{nick} #{message}, user_list: #{user_list}")
    user_list
  end

  defp broadcast(users, nick, message) do
    Enum.map(users, fn {_, node} ->
      Task.async(fn ->
        cast(node, { :message, nick, message })
      end)
    end)
    |> Enum.map(&Task.await/1)
  end

  defp call(node, args) do
    GenServer.call({ :client, node }, args, :infinity)
  end

  defp cast(node, args) do
    GenServer.cast({ :client, node }, args)
  end
end
