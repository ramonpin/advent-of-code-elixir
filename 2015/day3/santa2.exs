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
    do: route(instructions, [{0, 0}, {0, 0}], MapSet.new([{0, 0}]))

  def route([], _, houses),
    do: houses

  def route([current_santa], [pos_santa, pos_robot], houses) do
    pos_santa = flight(current_santa, pos_santa)
    houses = MapSet.put(houses, pos_santa)

    route([], [pos_santa, pos_robot], houses)
  end

  def route([current_santa, current_robot | rest], [pos_santa, pos_robot], houses) do
    pos_santa = flight(current_santa, pos_santa)
    pos_robot = flight(current_robot, pos_robot)
    houses = houses |> MapSet.put(pos_santa) |> MapSet.put(pos_robot)

    route(rest, [pos_santa, pos_robot], houses)
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
