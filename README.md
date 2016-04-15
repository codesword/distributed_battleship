# Distributed Battleship

## How to Run

From different terminals:

  1. start the server like this:

        > cd apps/bs_server
        > iex --sname server --cookie battleship-in-the-wild -S mix run

      If you are connecting from a different machine, start the server like this:

      > cd apps/bs_server
      > iex --name server@ip_address --cookie battleship-in-the-wild -S mix run


  2. then start the clients like this:

        > cd apps/bs_client
        > server=server@Macbook-Pro nick=john elixir --sname client -S mix run

Notice that the domain will be different (likely your machine's name), so change the command line accordingly.
