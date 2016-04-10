defmodule BSClient.Game.Ship do
  alias BSClient.Game.Config

  def valid_first_cell([max_fleet_index: max_index, size: size, orientation: orientation] = options) do
    row_index = Enum.random(0..max_index)
    column_index = Enum.random(0..max_index)
    in_valid? = [row_index, column_index] |> check_validity(orientation, max_index, size)
    cond do
      in_valid? ->  valid_first_cell(options)
      true -> cell([row_index, column_index])
    end
  end

  def positions([start: cell, size: size, orientation: :down ]) do
    [row, column] = cell
    row_index = Enum.find_index(Config.rows, fn(x) -> x == row end)
    [cell] ++ next_position(row_index: row_index + 1, column: column, size: size - 1, orientation: :down)
  end

  def positions([start: cell, size: size, orientation: :across ]) do
    [row, column] = cell
    column_index = Enum.find_index(Config.columns, fn(x) -> x == column end)
    [cell] ++ next_position(column_index: column_index + 1, row: row, size: size - 1, orientation: :across)
  end

  def cell([row_index, column_index]) do
    row = Enum.at(Config.rows, row_index)
    column = Enum.at(Config.columns, column_index)
    [row, column]
  end

  defp check_validity([_, column_index], :across,  max_index, size) do
    column_index + size > max_index + 1
  end

  defp check_validity([row_index, _], :down,  max_index, size) do
    row_index + size > max_index + 1
  end

  defp next_position([column_index: index, row: row, size: 0, orientation: :across]), do: []
  defp next_position([row_index: index, column: column, size: 0, orientation: :down]), do: []

  defp next_position([column_index: index, row: row, size: size, orientation: :across]) do
    cell = [row, Enum.at(Config.columns, index)]
    [cell] ++ next_position(column_index: index + 1, row: row, size: size - 1, orientation: :across)
  end

  defp next_position([row_index: index, column: column, size: size, orientation: :down]) do
    cell = [Enum.at(Config.rows, index), column]
    [cell] ++ next_position(row_index: index + 1, column: column, size: size - 1, orientation: :down)
  end
end
