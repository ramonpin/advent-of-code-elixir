defmodule Octopus do
  def grid(file) do
    data =
      File.stream!(file, mode: :line)
      |> Stream.map(&String.trim/1)

    for {line, row} <- Enum.with_index(data),
        {octopus, col} <- Enum.with_index(to_charlist(line)),
        into: %{},
        do: {{row, col}, octopus - ?0}
  end

  def step(grid) do
    flash(Map.keys(grid), grid, MapSet.new())
  end

  def flash([], grid, flashed), do: {grid, MapSet.size(flashed)}

  def flash([key | keys], grid, flashed) do
    value = grid[key]

    cond do
      is_nil(value) or key in flashed ->
        flash(keys, grid, flashed)

      value >= 9 ->
        flashed = MapSet.put(flashed, key)
        grid = Map.put(grid, key, 0)
        flash(neighbours(key) ++ keys, grid, flashed)

      true ->
        grid = Map.put(grid, key, value + 1)
        flash(keys, grid, flashed)
    end
  end

  def neighbours({row, col}) do
    candidates = for i <- -1..1, j <- -1..1, into: [], do: {row + i, col + j}
    Enum.reject(candidates, fn key -> key == {row, col} end)
  end

  def print({grid, flashes}) do
    for row <- 0..9 do
      IO.puts(for(col <- 0..9, do: grid[{row, col}] + ?0))
    end

    IO.puts("\nflashes: #{flashes}")
    IO.puts("------------------------------------------------------------------")
    grid
  end

  def run_steps(grid, n) when is_integer(n) do
    Enum.reduce(1..n, {grid, 0}, fn _, {grid, total_flashes} ->
      {grid, flashes} = step(grid)
      {grid, total_flashes + flashes}
    end)
  end

  def first_flash(file) do
    file
    |> grid()
    |> first_flash(1)
    |> print()

    :ok
  end

  def first_flash(grid, step_no) do
    case step(grid) do
      {grid, 100} -> {grid, step_no}
      {grid, _} -> first_flash(grid, step_no + 1)
    end
  end

  def run(file) do
    file
    |> grid()
    |> run_steps(100)
    |> print()

    :ok
  end
end
