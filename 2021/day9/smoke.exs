defmodule Smoke do
  def data(file) do
    File.stream!(file, mode: :line)
    |> Stream.with_index()
    |> Stream.flat_map(&coords/1)
    |> Map.new()
  end

  def get_minimuns(smoke_map) do
    Enum.filter(smoke_map, fn {pos, v} -> check_minimun(pos, v, smoke_map)  end)
  end

  def calc_total_risk(minimuns) do
    Enum.reduce(minimuns, 0 , fn {_, v}, risk -> risk + v + 1 end)
  end

  def run(file) do
    file
    |> then(&data/1)
    |> then(&get_minimuns/1)
    |> then(&calc_total_risk/1)
  end

  defp coords({line, i}) do
    line
    |> String.trim()
    |> to_charlist()
    |> Enum.with_index()
    |> Enum.map(fn {c, j} -> {{i, j}, c - ?0} end)
  end

  defp check_minimun({r, c}, current, smoke_map) do
    neightbours = neightbours(r, c)
    Enum.all?(neightbours, fn pos -> Map.get(smoke_map, pos, 10) > current end)
  end

  defp neightbours(r, c) do
    [
      {r - 1, c},
      {r, c - 1},
      {r, c + 1},
      {r + 1, c}
    ]
  end
end
