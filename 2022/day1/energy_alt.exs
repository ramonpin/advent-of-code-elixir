defmodule ElfEnergy do
  def load_data(file) do
    File.stream!(file, mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_by(fn line -> line == "" end)
    |> Stream.reject(fn line -> line == [""] end)
    |> Stream.map(fn elf -> Enum.map(elf, &String.to_integer/1) end)
    |> Stream.map(&Enum.sum/1)
  end

  def top_three_elfs(elfs) do
    elfs
    |> Enum.sort(:desc)
    |> Enum.take(3)
  end

  def run_part1(file) do
    file
    |> load_data()
    |> Enum.max()
  end

  def run_part2(file) do
    file
    |> load_data()
    |> top_three_elfs()
    |> Enum.sum()
  end
end


IO.puts(ElfEnergy.run_part1("sample.txt") == 24000)
IO.puts(ElfEnergy.run_part1("input.txt") == 71924)
IO.puts(ElfEnergy.run_part2("sample.txt") == 45000)
IO.puts(ElfEnergy.run_part2("input.txt") == 210406)
