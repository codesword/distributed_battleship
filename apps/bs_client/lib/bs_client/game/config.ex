defmodule BSClient.Game.Config do
  @rows ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"]
  @columns ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
  @ships [2, 3, 4, 5]
  @ship_name %{ 2 => "W", 3 => "X", 4 => "Y", 5 => "Z" }
  @units ["two units", "three units", "four units", "five units"]

  def rows, do: @rows
  def columns, do: @columns
  def ships, do: @ships
  def units, do: @units
  def ship_name, do: @ship_name
end
