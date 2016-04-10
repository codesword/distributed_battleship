defmodule BSClient.Game.Fleet do
  alias BSClient.Game.Config

  def without_ships(size) do
    rows = Enum.take(Config.rows, size)
    columns = Enum.take(Config.columns, size)
    for a <- rows, into: %{} do
       {a, (for b <- columns, into: %{}, do: {b, [ship: :none, status: "_"]}) }
    end
  end

  def ship_overlap?(fleet, ship_position) do
    Enum.any?(ship_position,  fn(cell) ->
      [row, column] = cell
      fleet[row][column][:ship] != :none
    end)
  end

  def ship_sunk?(fleet, ship_size) do
    Enum.all?(fleet,  fn({_, row}) ->
      Enum.filter(row, fn({_, cell}) -> cell[:ship] == ship_size end)
      |> Enum.all?(fn({_, cell}) -> cell[:status] == "H" end)
    end)
  end

  def sunk?(fleet) do
    (for {key, row} <- fleet,
      {ckey, colomn} <- row,
      row[ckey][:ship] != :none,
      row[ckey][:status] != "H",
      do: [row[ckey][:ship]])
    |> Enum.empty?
  end

  def display(fleet) do
    row_zero = Enum.take(Config.columns, Enum.count(fleet)) |> Enum.join(" ")
    IO.puts ""
    fleet
    |> format_for_display
    |> Map.put("@", row_zero)
    |> Enum.each(fn({k, v}) -> IO.puts "#{k}|#{v}" end)
  end

  def update_with_ship(fleet, [], ship_size), do: fleet

  def update_with_ship(fleet, [head|tail], ship_size) do
    fleet
    |> update_cell_on_ship_creation(head, ship_size)
    |> update_with_ship(tail, ship_size)
  end

  def update_cell_on_play(fleet, [row, column], status) do
    Map.update!(fleet, row, fn(x) ->
      Map.update!(x, column, fn(_v) -> [ship: _v[:ship], status: status] end)
    end)
  end

  defp format_for_display(fleet) do
    for {row_key, value} <- fleet, into: %{} do
      row_value = (for {_column, pos} <- value, do: pos[:status]) |> Enum.join("|")
      { row_key, row_value }
    end
  end

  defp update_cell_on_ship_creation(fleet, [row, column], ship_size) do
    Map.update!(fleet, row, fn(x) ->
      name = Config.ship_name[ship_size]
      Map.update!(x, column, fn(_v) -> [ship: ship_size, status: name] end)
    end)
  end
end
