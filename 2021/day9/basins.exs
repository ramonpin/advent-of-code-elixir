defmodule Basins do
  @moduledoc """
  Implements part-2 of the exercise. Delegates reusable code to part-1
  solution found at 'smoke.exs'.

  To load this in iex use: c(["smoke.exs", "basins.exs"])
  """

  defdelegate data(file), to: Smoke
  defdelegate get_minimuns(smoke_map), to: Smoke
  defdelegate neightbours(r, c), to: Smoke

  def run(file) do
    smoke_map = data(file)

    smoke_map
    |> get_minimuns
    |> get_basins_size(smoke_map)
    |> Enum.sort(&>/2)
    |> Enum.take(3)
    |> Enum.product()
  end

  def get_basins_size(minimuns, smoke_map) do
    Enum.map(minimuns, fn {minimun, _} ->
      minimun
      |> get_basin(smoke_map)
      |> MapSet.size()
    end)
  end

  def get_basin(minimun, smoke_map) do
    initial_set = MapSet.new([minimun])
    get_basin(initial_set, initial_set, smoke_map)
  end

  defp get_basin(positions, new_positions, smoke_map) do
    {positions, new_positions} =
      for {r, c} <- new_positions,
          neightbour <- neightbours(r, c),
          not MapSet.member?(positions, neightbour),
          Map.get(smoke_map, neightbour, 9) < 9,
          reduce: {positions, MapSet.new()} do
        {positions, new_positions} ->
          {
            MapSet.put(positions, neightbour),
            MapSet.put(new_positions, neightbour)
          }
      end

    if MapSet.size(new_positions) == 0 do
      positions
    else
      get_basin(positions, new_positions, smoke_map)
    end
  end
end

IO.puts(Basins.run("sample.txt") == 1134)
IO.puts(Basins.run("input.txt") == 987_840)
