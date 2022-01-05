defmodule Santa do
  def data(file) do
    file
    |> File.stream!([], 1)
    |> Enum.to_list()
  end

  def run(file) do
    file
    |> data()
    |> route()
    |> MapSet.size()
  end

  def route(instructions),
    do: route(instructions, {0, 0}, MapSet.new([{0, 0}]))

  def route([], _, houses),
    do: houses

  def route([current | rest], pos, houses) do
    pos = flight(current, pos)
    route(rest, pos, MapSet.put(houses, pos))
  end

  def flight(">", {x, y}),
    do: {x + 1, y}

  def flight("<", {x, y}),
    do: {x - 1, y}

  def flight("v", {x, y}),
    do: {x, y + 1}

  def flight("^", {x, y}),
    do: {x, y - 1}
end
