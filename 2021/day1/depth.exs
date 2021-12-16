defmodule Depth do
  def data(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_int!/1)
  end

  def analyzer(data) do
    data
    |> Stream.chunk_every(2, 1, :discard)
    |> Stream.map(&slope/1)
  end

  def run(file) do
    file
    |> data()
    |> analyzer()
    |> Stream.filter(fn slope -> slope == "increase" end)
    |> Enum.count()
  end

  defp parse_int!(n) do
    case Integer.parse(n) do
      {n, ""} -> n
    end
  end

  defp slope([n, m]) do
    if n > m do
      "decrease"
    else
      "increase"
    end
  end
end
