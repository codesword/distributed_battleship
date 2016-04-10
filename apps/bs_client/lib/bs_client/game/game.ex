defmodule BSClient.Game.Engine do
  alias BSClient.Game.Computer
  alias BSClient.Game.Fleet
  alias BSClient.Game.Human
  alias BSClient.Game.Config
  alias BSClient.Game.State

  def setup([board_size: size, ship_count: count]) do
    computer_fleet = Computer.generate_fleet(size, count)
    human_fleet = Human.generate_fleet(size, count)
    { computer_fleet, human_fleet }
  end

  def play({ _computer_fleet, _human_fleet }, :computer, :game_over), do: :game_over
  def play({ _computer_fleet, _human_fleet }, :human, :game_over) do
    total_time = State.total_time
    shots = State.get(:shots)
    IO.puts "Sorry!!! You lost the game"
    IO.puts "It took computer #{shots + 1} shots to sink all your ships"
    IO.puts "The game lasted for #{total_time}"
  end

  def play({ computer_fleet, human_fleet }, :human,  _status) do
    IO.puts "Your turn! Here's what you know:"
    Fleet.display(human_fleet)
    IO.puts "Your turn! Here's my fleet arrangement:"
    Fleet.display(computer_fleet)
    { status, computer_fleet, ship_size } = shoot(:human, computer_fleet)
    State.inc_shots
    display_status(status, :human, ship_size)
    play({ computer_fleet, human_fleet }, :computer,  status)
  end

  def play({ computer_fleet, human_fleet }, :computer, _status) do
    IO.puts "My turn! Here's your map:"
    Fleet.display(human_fleet)
    { status, human_fleet, _ship_size } = shoot(:computer, human_fleet)
    play({ computer_fleet, human_fleet }, :human, status)
  end

  def shoot(:computer, fleet, :taken), do: shoot(:computer, fleet)

  def shoot(:human, fleet, :taken) do
    IO.puts "This coordinate has already been shot:"
    shoot(:human, fleet)
  end

  def shoot(:computer, fleet) do
    fleet_size = Enum.count(fleet) - 1
    row = Enum.take(Config.rows, fleet_size) |> Enum.random
    column = Enum.take(Config.columns, fleet_size) |> Enum.random
    [row, column]
    |> update_cell_on_play(fleet, :computer)
  end

  def shoot(:human, fleet) do
    IO.gets("Enter a coordinate to shoot at:")
    |> String.rstrip(?\n)
    |> Human.cell_from_coordinate
    |> update_cell_on_play(fleet, :human)
  end

  def update_cell_on_play([row, column], fleet, player) do
    cond do
      fleet[row][column][:status] == "O" || fleet[row][column][:status] == "H"
        -> shoot(player, fleet, :taken)
      fleet[row][column][:ship] == :none
        -> new_fleet = Fleet.update_cell_on_play(fleet, [row, column], "O")
          { :miss, new_fleet, 0 }
      fleet[row][column][:ship] != :none
        -> hit_ship(fleet, [row, column])
    end
  end

  def hit_ship(fleet_, [row, column]) do
    fleet = Fleet.update_cell_on_play(fleet_, [row, column], "H")
    ship_size = fleet[row][column][:ship]
    cond do
      Fleet.sunk?(fleet) -> { :game_over, fleet, 0 }
      Fleet.ship_sunk?(fleet, ship_size) -> { :ship_sunk, fleet, ship_size}
      true -> {:hit_ship, fleet, 0}
    end
  end

  def display_status(:miss, :human, _) do
    IO.puts "You didn't hit any enemy ship"
  end

  def display_status(:hit_ship, :human, _) do
    IO.puts "You hit an enemy ship"
  end

  def display_status(:game_over, :human, _) do
    total_time = State.total_time
    shots = State.get(:shots)
    IO.puts "Congratulations!!! You won the game"
    IO.puts "It took you #{shots} shots to sink the opponent’s ships"
    IO.puts "The game lasted for #{total_time}"
  end

  def display_status(:ship_sunk, :human, ship_size) do
    IO.puts "You have sunk an enemy ship. The size of the ship is: #{ship_size}"
  end
end
