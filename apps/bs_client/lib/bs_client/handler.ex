defmodule BSClient.Handler do
  use GenServer

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
end
