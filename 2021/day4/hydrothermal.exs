defmodule Hydrothermal do
  def data(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " -> "))
    |> Stream.map(&split_coords/1)
    |> Stream.map(&coords_ranges/1)
  end

  def run(file) do
    file
    |> data()
    |> Stream.flat_map(&expand_ranges/1)
    |> Enum.group_by(& &1)
    |> Enum.filter(fn {_point, list} -> length(list) > 1 end)
    |> Enum.count()
  end

  def expand_ranges([xa..xb = x_range, ya..yb = y_range]) do
    cond do
      xa == xb || ya == yb ->
        for x <- x_range, y <- y_range, do: {x, y}

      true ->
        Enum.zip(x_range, y_range)
    end
  end

  defp split_coords([start, finish]) do
    start = start |> String.split(",") |> coords_numbers()
    finish = finish |> String.split(",") |> coords_numbers()

    [start, finish]
  end

  defp coords_numbers([x, y]) do
    {x, ""} = Integer.parse(x)
    {y, ""} = Integer.parse(y)

    [x, y]
  end

  defp coords_ranges([[a, b], [c, d]]) do
    [a..c, b..d]
  end
end
