defmodule SeaCucumbers do
  def data(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_charlist/1)
    |> cucumbers_positions()
  end

  defp cucumbers_positions(cucumbers) do
    for {row_cucumbers, row} <- Enum.with_index(cucumbers),
        {cucumber, col} <- Enum.with_index(row_cucumbers),
        cucumber != ?.,
        into: %{} do
      {{row, col}, cucumber}
    end
  end

  def dimensions(cucumbers) do
    Enum.reduce(cucumbers, {0, 0}, fn {{row, col}, _}, {max_row, max_col} ->
      {max(row, max_row), max(col, max_col)}
    end)
  end

  def show(cucumbers, {max_row, max_col}) do
    for row <- 0..max_row do
      for col <- 0..max_col do
        cucumber = Map.get(cucumbers, {row, col}, ?.)
        IO.write(<<cucumber>>)
      end

      IO.write("\n")
    end

    IO.write("\n")
  end

  def animate(cucumbers) do
    dimensions = dimensions(cucumbers)

    Enum.each(stream(cucumbers), fn {generation, _, cucumbers} ->
      IEx.Helpers.clear()
      IO.puts("Generation: #{generation}")
      show(cucumbers, dimensions)
      Process.sleep(1_000)
    end)
  end

  def fixed_point(cucumbers) do
    stream(cucumbers)
    |> Stream.filter(fn {_, prev, current} -> prev == current end)
    |> Enum.at(0)
  end

  defp stream(cucumbers) do
    dimensions = dimensions(cucumbers)

    Stream.iterate({0, nil, cucumbers}, fn {generation, _prev, current} ->
      {generation + 1, current, step_move(current, dimensions)}
    end)
  end

  defp step_move(cucumbers, dimensions) do
    cucumbers =
      for {_, type} = cucumber <- cucumbers, into: %{} do
        if type == ?>, do: move_cucumber(cucumber, cucumbers, dimensions), else: cucumber
      end

    for {_, type} = cucumber <- cucumbers, into: %{} do
      if type == ?v, do: move_cucumber(cucumber, cucumbers, dimensions), else: cucumber
    end
  end

  defp move_cucumber({{row, col}, ?>} = current, cucumbers, {_, max_col}) do
    target = if col + 1 > max_col, do: {row, 0}, else: {row, col + 1}
    neightbour = Map.get(cucumbers, target, :empty)
    if neightbour == :empty, do: {target, ?>}, else: current
  end

  defp move_cucumber({{row, col}, ?v} = current, cucumbers, {max_row, _}) do
    target = if row + 1 > max_row, do: {0, col}, else: {row + 1, col}
    neightbour = Map.get(cucumbers, target, :empty)
    if neightbour == :empty, do: {target, ?v}, else: current
  end
end
