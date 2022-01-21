defmodule PQ do
  @moduledoc """
  This module allows us to maintain all the nodes ordered by weight so
  get the closet one is just a matter of taking the head of the list,
  """

  def new(),
    do: []

  def add([{cur_weight, _} | _] = list, value, weight) when weight <= cur_weight,
    do: [{weight, value} | list]

  def add([head | tail], value, weight),
    do: [head | add(tail, value, weight)]

  def add([], value, weight),
    do: [{weight, value}]
end

defmodule RepeatedGraph do
  @moduledoc """
  This module implements the repetition algorithm for a given original graph and number
  of repetitions. In this way we do not need to create the repeated graph in memory and
  lazily compute the accessed nodes.
  """

  defstruct data: %{}, width: 0, height: 0, width_repetition: 0, height_repetition: 0

  defp data(file) do
    for {line, row} <- Stream.with_index(File.stream!(file, mode: :line)),
        {char, col} <- Enum.with_index(to_charlist(line)),
        char != ?\n,
        into: %{},
        do: {{row, col}, char - ?0}
  end

  def new(file, width_repetition, height_repetition) do
    graph = data(file)
    {{max_row, max_col}, _} = Enum.max(graph)

    %__MODULE__{
      data: graph,
      width: max_row + 1,
      height: max_col + 1,
      width_repetition: width_repetition,
      height_repetition: height_repetition
    }
  end

  def get(rpmap, {row, col}) do
    {row_quadrant, row} = div_rem(row, rpmap.width)
    {col_quadrant, col} = div_rem(col, rpmap.height)

    if row_quadrant < rpmap.width_repetition and
         col_quadrant < rpmap.height_repetition and
         row >= 0 and
         col >= 0 do
      increment = row_quadrant + col_quadrant
      rem(rpmap.data[{row, col}] + increment - 1, 9) + 1
    else
      nil
    end
  end

  def dimensions(graph) do
    {
      graph.width * graph.width_repetition - 1,
      graph.height * graph.height_repetition - 1
    }
  end

  def keys(graph) do
    {max_row, max_col} = dimensions(graph)

    for row <- 0..max_row,
        col <- 0..max_col,
        into: [],
        do: {row, col}
  end

  defp div_rem(n, m), do: {div(n, m), rem(n, m)}
end

defmodule Network do
  @moduledoc """
  This module implements the solution to the puzzle by means of the Dijkstra algorith
  for shortest (weighted) path.
  """

  def run(file, repetitions \\ 1) do
    graph = RepeatedGraph.new(file, repetitions, repetitions)
    source = {0, 0}
    dest = RepeatedGraph.dimensions(graph)

    shortest(graph, source, dest)
  end

  def shortest(graph, source, dest) do
    weights = %{source => 0}
    queue = PQ.new() |> PQ.add({0, 0}, 0)

    recur(graph, weights, queue, dest)
  end

  defp recur(graph, weights, queue, dest) do
    [{_, u} | queue] = queue

    if u == dest do
      weights[u]
    else
      {weights, queue} =
        for v <- neighbours(u),
            cur_weight = RepeatedGraph.get(graph, v),
            cur_weight != nil,
            total_weight = weights[u] + cur_weight,
            total_weight < Map.get(weights, v, :infinity),
            reduce: {weights, queue} do
          {weights, queue} ->
            weights = Map.put(weights, v, total_weight)
            queue = PQ.add(queue, v, total_weight)
            {weights, queue}
        end

      recur(graph, weights, queue, dest)
    end
  end

  defp neighbours({row, col}) do
    [
      {row - 1, col},
      {row, col - 1},
      {row, col + 1},
      {row + 1, col}
    ]
  end
end

IO.puts "sample x 1 -> #{Network.run("sample.txt")}"
IO.puts "input  x 1 -> #{Network.run("input.txt")}"
IO.puts "sample x 5 -> #{Network.run("sample.txt", 5)}"
IO.puts "input  x 5 -> #{Network.run("input.txt", 5)}"
