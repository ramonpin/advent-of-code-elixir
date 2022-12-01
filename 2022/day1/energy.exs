defmodule ElfEnergy do
  def load_data(file) do
    File.stream!(file, mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_by(fn line -> line == "" end)
    |> Stream.reject(fn line -> line == [""] end)
    |> Stream.map(fn elf -> Enum.map(elf, &String.to_integer/1) end)
    |> Enum.with_index(1)
  end

  def max_calories_elf(elfs) do
    elfs
    |> Stream.map(fn {calories, elf} -> {Enum.sum(calories), elf} end)
    |> Enum.max_by(fn {calories, _} -> calories end)
    |> then(fn {calories, _} -> calories end)
  end

  def top_three_elfs(elfs) do
    elfs
    |> Stream.map(fn {calories, elf} -> {Enum.sum(calories), elf} end)
    |> Enum.sort_by(fn {calories, _} -> calories end, :desc)
    |> Enum.take(3)
  end

  def run_part1(file) do
    file
    |> load_data()
    |> max_calories_elf()
  end

  def run_part2(file) do
    file
    |> load_data()
    |> top_three_elfs()
    |> Enum.reduce(0, fn {calories, _}, acc -> acc + calories end)
  end
end


IO.puts(ElfEnergy.run_part1("sample.txt") == 24000)
IO.puts(ElfEnergy.run_part1("input.txt") == 71924)
IO.puts(ElfEnergy.run_part2("sample.txt") == 45000)
IO.puts(ElfEnergy.run_part2("input.txt") == 210406)
