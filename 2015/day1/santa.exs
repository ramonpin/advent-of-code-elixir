defmodule Santa do
  def data(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Enum.take(1)
    |> List.first()
    |> String.to_char_list()
  end

  def run(file) do
    file
    |> data()
    |> process()
  end

  def process(instructions),
    do: process(instructions, 0)

  defp process([], floor),
    do: floor

  defp process([?( | rest], floor),
    do: process(rest, floor + 1)

  defp process([?) | rest], floor),
    do: process(rest, floor - 1)
end
