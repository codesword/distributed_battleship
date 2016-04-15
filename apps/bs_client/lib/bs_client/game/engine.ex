defmodule BSClient.Game.Engine do
  alias BSClient.Game.Computer
  alias BSClient.Game.Fleet
  alias BSClient.Game.Human
  alias BSClient.Game.Config
  alias BSClient.Game.State
  alias BSClient.ServerProcotol

  def setup([board_size: size, ship_count: count, opponent: :computer]) do
    computer_fleet = Computer.generate_fleet(size, count)
    State.start_time
    human_fleet = Human.generate_fleet(size, count)
    {computer_fleet, human_fleet}
  end

  def setup([board_size: size, ship_count: count, opponent: :human, name: name]) do
    ServerProcotol.layout_fleet(name, {size, count})
    State.start_time
    State.put(:my_fleet, Human.generate_fleet(size, count))
    :ok
  end

  def play({_computer_fleet,_human_fleet}, :computer, :game_over), do: :game_over
  def play({_computer_fleet, _human_fleet}, :human, :game_over) do
    IO.puts game_over
  end

  def play({ computer_fleet, human_fleet }, :human,  _status) do
    IO.puts "Your turn! Here's what you know:"
    Fleet.display(human_fleet)
    { status, computer_fleet, ship_size } = shoot(:human, computer_fleet)
    State.inc_shots
    display_status(status, :human, ship_size)
    play({computer_fleet, human_fleet}, :computer,  status)
  end

  def play({computer_fleet, human_fleet}, :computer, _status) do
    IO.puts "My turn! Here's your map:"
    Fleet.display(human_fleet)
    { status, human_fleet, _ship_size } = shoot(:computer, human_fleet)
    play({computer_fleet, human_fleet}, :human, status)
  end

  def play(_, :human, nick) do
    select_coord(nick) |> ServerProcotol.shoot(nick)
  end

  def play(:human, coord, nick) do
    fleet = State.get(:my_fleet)
    { status, fleet, ship_size } = shoot(:human, fleet, coord)
    IO.puts "Your turn! Here's what you know:"
    Fleet.display(fleet)
    State.put(:my_fleet, fleet)
    State.inc_shots
    ServerProcotol.display_status(status, nick, ship_size)
    if status == :game_over do
      IO.puts game_over(nick)
    else
      select_coord(nick)
        |> ServerProcotol.shoot(nick)
    end
    {:noreply, []}
  end

  def select_coord(nick) do
    coord = IO.gets("Enter a coordinate to shoot at:")
      |> String.rstrip(?\n)
    case ServerProcotol.valid_shoot?(coord, nick) do
      false -> coord
      true ->
        IO.puts "This coordinate has already been shot:"
        select_coord(nick)
    end
  end

  def send_message(:game_over, nick) do
    ServerProcotol.private_message(nick, game_over("your opponent"))
  end

  def send_message(_, _nick), do: nil

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

  def shoot(:human, fleet, coord) do
    coord
    |> Human.cell_from_coordinate
    |> update_cell_on_play(fleet, :human)
  end

  def valid_shoot?(coord) do
    [row, column] = coord |> Human.cell_from_coordinate
    fleet = State.get(:my_fleet)
    fleet[row][column][:status] == "O" || fleet[row][column][:status] == "H"
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

  def game_over(nick \\ "computer") do
    total_time = State.total_time
    shots = State.get(:shots)
    """
    Sorry!!! You lost the game"
    It took #{nick} #{shots + 1} shots to sink all your ships
    The game lasted for #{total_time}
    """
  end
end
