defmodule BSClient.Game.Human do
  alias BSClient.Game.Message
  alias BSClient.Game.Ship
  alias BSClient.Game.Config
  alias BSClient.Game.Fleet

  def generate_fleet(size, ship_count) do
    IO.puts Message.human_fleet(ship_count)
    ships = Enum.take(Config.ships, ship_count)
    Fleet.without_ships(size)
    |> fleet(ships)
  end

  def fleet(fleet, []), do: fleet

  def fleet(fleet, [head| tail]) do
    ship_position = ship_without_overlap(fleet, head)
    Fleet.update_with_ship(fleet, ship_position, head) |> fleet(tail)
  end

  def ship_without_overlap(fleet, ship_size) do
    ship_info = ask_for_ship_info(ship_size - 2)
    [first_coordinate, _] = String.split(ship_info, " ")
    list = String.to_char_list(ship_info)
    orientation = cond do
      Enum.at(list, 0) == Enum.at(list, 3) -> :across
      true -> :down
    end
    first_cell = cell_from_coordinate(first_coordinate)
    ship_position_ = Ship.positions(start: first_cell, size: ship_size, orientation: orientation)
    if Fleet.ship_overlap?(fleet, ship_position_) do
      IO.puts "Error: This ship overlaps with another ship. "
      ship_without_overlap(fleet, ship_size)
    else
      ship_position_
    end
  end

  def cell_from_coordinate(coordinate) do
    String.split(coordinate, "", trim: true)
  end

  defp ask_for_ship_info(ship_no) do
    IO.gets("Enter the squares for the #{Enum.at(Config.units, ship_no)} ship: ")
    |> String.rstrip(?\n)
  end
end
