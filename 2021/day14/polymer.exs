defmodule Polymer do
  def rules(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " -> "))
    |> Map.new(fn [pair, new] ->
      {to_charlist(pair), to_charlist(String.at(pair, 0) <> new)}
    end)
  end

  def step(instructions, rules) do
    instructions
    |> String.to_charlist()
    |> Enum.chunk_every(2, 1)
    |> Enum.map(fn cod -> Map.get(rules, cod, cod) end)
    |> Enum.join()
  end

  def run(instructions, rules, steps) do
    1..steps
    |> Enum.reduce(instructions, fn _step, polymer ->
      step(polymer, rules)
    end)
  end

  def stats(polymer) do
    polymer
    |> String.to_charlist()
    |> Enum.frequencies_by(&<<&1>>)
  end

  def score(stats) do
    stats
    |> Map.values()
    |> Enum.min_max()
    |> then(fn {min, max} -> max - min end)
  end

  def polymer_score(instructions, rules_file, steps) do
    instructions
    |> run(rules(rules_file), steps)
    |> stats()
    |> score()
  end
end

"BSONBHNSSCFPSFOPHKPK"
|> Polymer.polymer_score("input.txt", 10)
|> IO.puts()
