defmodule BSClient.Game.Message do
  def welcome do
    """
    \n
    Welcome to BSClient.Game
    Would you like to (p)lay, read the (i)nstructions, or (q)uit?
    """
  end

  def level do
    """
    \n
    Difficulty Level
    Would you like to play in (b)eginner, (i)ntermidiate or (a)dvance mode
    """
  end

  def mode do
    """
    \n
    Game Mode
    Would you like to play with a (h)uman player or (c)omputer player
    """
  end

  def human_fleet(2) do
    """
    I have laid out my ships on the grid.
    You now need to layout your two ships.
    The first is two units long and the
    second is three units long.
    The grid has A1 at the top left and D4 at the bottom right.
    """
  end

  def human_fleet(3) do
    """
    I have laid out my ships on the grid.
    You now need to layout your three ships.
    The first is two units long, the
    second is three units long and the
    third is four units long.
    The grid has A1 at the top left and H8 at the bottom right.
    """
  end

  def human_fleet(4) do
    """
    I have laid out my ships on the grid.
    You now need to layout your four ships.
    The first is two units long, the
    second is three units long, the
    third is four units long and the
    fourth is five units long.
    The grid has A1 at the top left and L12 at the bottom right.
    """
  end

  def instruction do
    """
    \n
    BSClient.Game (or BSClient.Games) is a game for two players where you try to guess the location of five ships your opponent has hidden on a grid. Players take turns calling out a row and column, attempting to name a square containing enemy ships. Originally published as Broadsides by Milton Bradley in 1931, the game was eventually reprinted as BSClient.Game.

    Players: 2 players

    Contents: Each player gets a board with two grids, five ships, and a bunch of hit and miss markers. (Alternatively, the game can be played with pencil and paper by drawing the grids. Here are the rules for that game, known as Salvo.)

    Goal: To sink all of your opponent's ships by correctly guessing their location.

    Setup

    Give each player a board with two grids, one of each type of ship, and a bunch of hit and miss markers. Pen and paper players should note there is one length 2 ship, two length 3 ships, one length 4 ship, and one length 5 ship.

    Secretly place your ships on the lower grid.Each ship must be placed horizontally or vertically (not diagonally) across grid spaces, and can't hang over the grid. Ships can touch each other, but can't both be on the same space.

    Play

    Players take turns firing a shot to attack enemy ships.

    On your turn, call out a letter and a number of a row and column on the grid. Your opponent checks that space on their lower grid, and says "miss" if there are no ships there, or "hit" if you guessed a space that contained a ship.

    Mark your shots on your upper grid, with white pegs for misses and red pegs for hits, to keep track of your guesses.

    When one of your ships is hit, put a red peg into that ship on your lower grid at the location of the hit. Whenever one of your ships has every slot filled with red pegs, you must announce to your opponent that he has sunk your ship.

    Victory: The first player to sink all opposing ships wins.

    Salvo Variant

    To speed up the game, some players play a Salvo variant where you get multiple shots per turn. On your turn, you get to take one shot for each ship you have remaining in your fleet. Once you have announced all of your shots (five, at the beginning of the game), your opponent tells you which ones were hits.
    """
  end
end
