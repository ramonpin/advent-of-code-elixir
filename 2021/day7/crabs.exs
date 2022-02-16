defmodule Crabs do

  def data(file) do
    file
    |> File.read!()
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def min_cost(crabs, cost_func \\ &simple_cost/2) do
    crabs
    |> Enum.min_max()
    |> then(fn {min, max} -> Range.new(min, max) end)
    |> Enum.map(&{&1, cost_func.(crabs, &1)})
    |> Enum.min_by(fn {_, cost} -> cost end)
  end

  def simple_cost(crabs, position) when is_list(crabs) do
    crabs
    |> Enum.map(&abs(position - &1))
    |> Enum.sum()
  end

  def crab_cost(crabs, position) do
    crabs
    |> Enum.map(&abs(position - &1))
    |> Enum.map(&abs(div(&1 * (&1 + 1), 2)))
    |> Enum.sum()
  end

  def run(file, cost_func \\ &simple_cost/2) do
    file
    |> data()
    |> min_cost(cost_func)
  end
end

IO.inspect(Crabs.run("sample.txt") == {2, 37})
IO.inspect(Crabs.run("input.txt") == {340, 345197})

IO.inspect(Crabs.run("sample.txt", &Crabs.crab_cost/2) == {5, 168})
IO.inspect(Crabs.run("input.txt", &Crabs.crab_cost/2) == {475, 96361606})
