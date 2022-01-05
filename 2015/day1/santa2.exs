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
    do: process(instructions, 0, 0)

  defp process(_, -1, char),
    do: char

  defp process([], _, _),
    do: :not_found

  defp process([?( | rest], floor, char),
    do: process(rest, floor + 1, char + 1)

  defp process([?) | rest], floor, char),
    do: process(rest, floor - 1, char + 1)
end
