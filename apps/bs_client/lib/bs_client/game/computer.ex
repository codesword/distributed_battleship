defmodule BSClient.Game.Computer do
  alias BSClient.Game.Ship
  alias BSClient.Game.Config
  alias BSClient.Game.Fleet

  def generate_fleet(size, ship_count) do
    Fleet.without_ships(size)
    |> fleet(Enum.take(Config.ships, ship_count))
  end

  def fleet(fleet, []), do: fleet

  def fleet(fleet, [head| tail]) do
    orientation = Enum.random([:across, :down])
    ship_positions = ship_without_overlap(fleet, { head, orientation })
    Fleet.update_with_ship(fleet, ship_positions, head) |> fleet(tail)
  end

  def ship_without_overlap(fleet, { size, orientation }) do
    max_index = map_size(fleet) - 1
    cell = Ship.valid_first_cell(max_fleet_index: max_index, size: size, orientation: orientation)
    ship_position = Ship.positions(start: cell, size: size, orientation: orientation)
    if Fleet.ship_overlap?(fleet, ship_position) do
      ship_without_overlap(fleet, { size, orientation })
    else
      ship_position
    end
  end
end
