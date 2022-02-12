defmodule LanterFish do
  def data(file) do
    file
    |> File.read!()
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def run(file, cycles) do
    file
    |> data()
    |> run_cycles(cycles)
    |> length()
  end

  def run_cycles(fish, cycles) do
    Enum.reduce(1..cycles, fish, fn _, fish ->
      run_cycle(fish)
    end)
  end

  defp run_cycle(fish) do
    Enum.reduce(fish, [], fn fish, next_generation ->
      if fish == 0 do
        [6, 8 | next_generation]
      else
        [fish - 1 | next_generation]
      end
    end)
  end
end

IO.puts(LanterFish.run("sample.txt", 18)  == 26)
IO.puts(LanterFish.run("sample.txt", 80)  == 5_934)
IO.puts(LanterFish.run("input.txt",  80)  == 35_9999)
