defmodule XMAS do
  def load_data(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end

  def run(file, n) do
    case process(n, load_data(file)) do
      :not_found -> :not_found
      list -> list |> Enum.min_max() |> Tuple.sum()
    end
  end

  def process(n, numbers),
    do: process(n, numbers, [], 0)

  defp process(n, [], _, _),
    do: :not_found

  defp process(n, _, cache, n),
    do: cache

  defp process(n, [m | rest], [], 0),
    do: process(n, rest, [m], m)

  defp process(n, [m | rest] = numbers, [_ | crest] = cache, sum) do
    if m + sum <= n do
      process(n, rest, cache ++ [m], m + sum)
    else
      process(n, crest ++ numbers, [], 0)
    end
  end
end
