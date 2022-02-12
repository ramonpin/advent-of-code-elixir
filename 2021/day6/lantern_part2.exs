defmodule LanterFish do
  def data(file) do
    file
    |> File.read!()
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.group_by(& &1)
    |> Map.new(fn {key, val} -> {key, length(val)} end)
  end

  def run_cycle(fish) do
    Enum.reduce(fish, %{}, fn {age, count}, new_fish ->
      if age == 0 do
        new_fish
        |> Map.update(6, count, fn current -> current + count end)
        |> Map.update(8, count, fn current -> current + count end)
      else
        new_fish
        |> Map.update(age - 1, count, fn current -> current + count end)
      end
    end)
  end

  def run_cycles(fish, cycles) do
    1..cycles
    |> Enum.reduce(fish, fn _, fish -> run_cycle(fish) end)
    |> Enum.reduce(0, fn {_, count}, acc -> acc + count end)
  end

  def run(file, cycles) do
    file
    |> data()
    |> run_cycles(cycles)
  end
end

IO.puts(LanterFish.run("sample.txt", 18)  == 26)
IO.puts(LanterFish.run("sample.txt", 80)  == 5_934)
IO.puts(LanterFish.run("input.txt",  80)  == 35_9999)

IO.puts(LanterFish.run("sample.txt", 256) == 26_984_457_539)
IO.puts(LanterFish.run("input.txt",  256) == 1_631_647_919_273)
