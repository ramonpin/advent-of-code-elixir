defmodule MapUtils do
  def reduce_values(map, func) do
    Map.new(map, fn {key, value} -> {key, func.(value)} end)
  end
end

defmodule Polymer do
  def rules(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " -> "))
    |> Map.new(fn [pair, new] -> {pair, new} end)
  end

  def pair_stats(instructions) do
    instructions
    |> to_charlist()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&List.to_string/1)
    |> Enum.frequencies()
  end

  def update_stats_step(_step, stats, rules) do
    Enum.reduce(stats, %{}, fn {cod, freq}, stats ->
      {cod_a, cod_b} = new_cods(cod, rules)

      stats
      |> Map.update(cod_a, freq, &(&1 + freq))
      |> Map.update(cod_b, freq, &(&1 + freq))
    end)
  end

  def stats_by_letter(stats, last_letter) do
    stats
    |> Enum.group_by(&String.at(elem(&1, 0), 0), &elem(&1, 1))
    |> MapUtils.reduce_values(&Enum.sum(&1))
    |> Map.update(last_letter, 1, &(&1 + 1))
  end

  def new_cods(cod, rules) do
    <<a::binary-size(1), b::binary-size(1)>> = cod
    c = Map.get(rules, cod, cod)
    {a <> c, c <> b}
  end

  def run(instructions, rules_file, steps) do
    last_letter = String.last(instructions)

    1..steps
    |> Enum.reduce(
      pair_stats(instructions),
      &update_stats_step(&1, &2, rules(rules_file))
    )
    |> stats_by_letter(last_letter)
  end

  defp polymer_score(polymer_stats) do
    polymer_stats
    |> Map.values()
    |> Enum.min_max()
    |> then(fn {min, max} -> max - min end)
  end

  def polymer_score(instructions, rules_file, steps) do
    instructions
    |> run(rules_file, steps)
    |> polymer_score()
  end
end

"BSONBHNSSCFPSFOPHKPK"
|> Polymer.polymer_score("input.txt", 40)
|> IO.puts()
