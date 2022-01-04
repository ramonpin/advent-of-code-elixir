defmodule XMAS do
  def load_data(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
  end

  def run(file, n) do
    {preamble, data} =
      file
      |> load_data()
      |> Enum.split(n)

    valid(preamble, data)
  end

  def valid(_, [], _), do: :valid

  def valid([_ | rest_preamble ] = preamble, [first | rest]) do
    if sums?(first, preamble) do
      valid(rest_preamble ++ [first], rest)
    else
      {:invalid, first}
    end
  end

  def sums?(number, []), do: false

  def sums?(number, [first | rest]) when number <= first,
    do: sums?(number, rest)

  def sums?(number, [first | rest]) do
    if (number - first) in rest do
      true
    else
      sums?(number, rest)
    end
  end
end
