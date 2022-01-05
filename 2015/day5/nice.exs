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
      [&has_three_vowels/1, &has_double_letter/1, &has_no_forbidden/1],
      fn rule -> rule.(name) end
    )
  end

  def has_three_vowels(name) do
    num_vowels =
      name
      |> Stream.filter(&(&1 in [?a, ?e, ?i, ?o, ?u]))
      |> Stream.take(3)
      |> Enum.count()

    num_vowels == 3
  end

  def has_double_letter(name) do
    double_letters =
      name
      |> Stream.chunk(2, 1, :discard)
      |> Stream.filter(fn [a, b] -> a == b end)
      |> Stream.take(1)
      |> Enum.count()

    double_letters == 1
  end

  def has_no_forbidden(name) do
    forbbiden =
      name
      |> Stream.chunk(2, 1, :discard)
      |> Stream.filter(&(&1 in ['ab', 'cd', 'pq', 'xy']))
      |> Stream.take(1)
      |> Enum.count()

    forbbiden == 0
  end
end
