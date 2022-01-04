defmodule XMAS do
  def load_data(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end

  def run(file, n) do
    case process(n, load_data(file), [], 0) do
      :not_found -> :not_found
      list -> list |> Enum.min_max() |> Tuple.sum()
    end
  end

  def process(n, [], _, _),
    do: :not_found

  def process(n, [m | rest], [], 0),
    do: process(n, rest, [m], m)

  def process(n, [m | rest] = numbers, [_ | crest] = cache, sum) do
    cond do
      m + sum == n ->
        cache ++ [m]

      m + sum < n ->
        process(n, rest, cache ++ [m], m + sum)

      true ->
        process(n, crest ++ numbers, [], 0)
    end
  end
end
