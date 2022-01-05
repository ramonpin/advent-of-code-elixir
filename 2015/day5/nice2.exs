defmodule Nice do
  def data(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_char_list/1)
  end

  def run(file) do
    file
    |> data()
    |> Stream.filter(&nice_name/1)
    |> Enum.count()
  end

  def nice_name(name) do
    Enum.all?(
      [&has_double_pair/1, &has_triplet/1],
      fn rule -> rule.(name) end
    )
  end

  def has_double_pair(name) do
    name
    |> Enum.chunk(2, 1, :discard)
    |> then(&contains_double_pair?/1)
  end

  def contains_double_pair?([first, second | rest]) do
    if(first in rest) do
      true
    else
      contains_double_pair?([second | rest])
    end
  end

  def contains_double_pair?(_), do: false

  def has_triplet(name) do
    name
    |> Stream.chunk(3, 1, :discard)
    |> Enum.any?(fn
      [a, b, a] -> true
      _ -> false
    end)
  end
end
