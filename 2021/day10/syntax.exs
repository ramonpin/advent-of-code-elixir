defmodule Syntax do
  @scores %{
    ?) => 3,
    ?] => 57,
    ?} => 1197,
    ?> => 25137
  }

  def data(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
  end

  def corrupted(string), do: corrupted(string, [])

  def find_corrupted(file) do
    file
    |> data()
    |> Enum.filter(&corrupted/1)
  end

  def score(file) do
    file
    |> data()
    |> Enum.map(&corrupted_score/1)
    |> Enum.sum()
  end

  def corrupted_score(line) do
    line
    |> corrupted()
    |> elem(1)
    |> then(&Map.get(@scores, &1, 0))
  end

  def incomplete_score(file) do
    file
    |> data()
    |> Enum.map(&corrupted/1)
    |> Enum.map(fn
      {:incomplete, symbols} -> score_symbols(symbols)
      _default -> 0
    end)
    |> Enum.reject(&(&1 == 0))
    |> Enum.sort()
    |> middle_point()
  end

  def middle_point(list) do
    list
    |> length()
    |> then(&Enum.at(list, div(&1, 2)))
  end

  def score_symbols(symbols) do
    Enum.reduce(symbols, 0, fn c, acc ->
      case c do
        ?) -> acc * 5 + 1
        ?] -> acc * 5 + 2
        ?} -> acc * 5 + 3
        ?> -> acc * 5 + 4
      end
    end)
  end

  # Opening
  defp corrupted(<<?(, rest::binary>>, stack), do: corrupted(rest, [?) | stack])
  defp corrupted(<<?[, rest::binary>>, stack), do: corrupted(rest, [?] | stack])
  defp corrupted(<<?{, rest::binary>>, stack), do: corrupted(rest, [?} | stack])
  defp corrupted(<<?<, rest::binary>>, stack), do: corrupted(rest, [?> | stack])

  # Closing
  defp corrupted(<<c, rest::binary>>, [c | stack]), do: corrupted(rest, stack)

  # Corrupted
  defp corrupted(<<c, _rest::binary>>, _stack), do: {:corrupted, c}

  # Valid
  defp corrupted(<<>>, []), do: {:valid, nil}

  # Incomplete
  defp corrupted(<<>>, stack), do: {:incomplete, stack}
end
