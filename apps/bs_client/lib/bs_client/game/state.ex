defmodule BSClient.Game.State do

  def start do
    Agent.start_link(fn -> %{} end, name: :game)
  end

  def get(key) do
    Agent.get(:game, &Map.get(&1, key))
  end

  def put(key, value) do
    Agent.update(:game, &Map.put(&1, key, value))
  end

  def inc_shots do
    current = get(:shots)
    put(:shots, current + 1)
  end

  def start_time do
    { _, seconds, _ } = :os.timestamp
    put(:start_time, seconds)
    put(:shots, 0)
  end

  def total_time do
    { _, seconds, _ } = :os.timestamp
    start_seconds = get(:start_time)
    "#{seconds - start_seconds} seconds"
  end
end
