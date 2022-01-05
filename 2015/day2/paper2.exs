defmodule Paper do

  def data(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "x"))
    |> Stream.map(&Enum.map(&1, fn n -> String.to_integer(n) end))
  end

  def run(file) do
    file
    |> data()
    |> process()
  end

  def process(presents) do
    presents
    |> Stream.map(&ribbon_for_present/1)
    |> Enum.sum()
  end

  def ribbon_for_present([l, w, h]) do
    dimensions = [l + w, l + h, w + h]
    2 * Enum.min(dimensions) + (l * w * h)
  end
end
