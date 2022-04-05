defmodule Paths do
  defmodule Path do
    defstruct nodes: MapSet.new(), path: [], consumed: false, last: nil
  end

  def run(file) do
    file
    |> data()
    |> paths()
    |> print_paths()
  end

  def data(file) do
    File.stream!(file, mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "-"))
    |> Stream.flat_map(fn [a, b] -> [[a, b], [b, a]] end)
    |> Enum.group_by(fn [a, _] -> a end, fn [_, b] -> b end)
  end

  def print_paths(paths) do
    # paths
    # |> Stream.map(fn path -> path.path end)
    # |> Stream.map(&Enum.reverse/1)
    # |> Enum.sort()
    # |> Enum.each(&IO.inspect/1)

    length(paths)
  end

  defp paths(connections) do
    initial_path = %Path{nodes: MapSet.new(["start"]), path: ["start"], last: "start"}
    paths(connections, [initial_path], [])
  end

  defp paths(connections, running_paths, valid_paths) do
    {running_paths, valid_paths} =
      for path <- running_paths,
          neightbour <- neightbours(connections, path.last),
          visitable(neightbour, path),
          reduce: {[], valid_paths} do
        {running_paths, valid_paths} ->
          path = add_node(path, neightbour)

          if path.last == "end" do
            {running_paths, [path | valid_paths]}
          else
            {[path | running_paths], valid_paths}
          end
      end

    if running_paths == [] do
      valid_paths
    else
      paths(connections, running_paths, valid_paths)
    end
  end

  defp neightbours(connections, node) do
    Map.get(connections, node)
  end

  defp add_node(path, node) do
    consumed = path.consumed or (String.upcase(node) != node and MapSet.member?(path.nodes, node))

    %Path{
      nodes: MapSet.put(path.nodes, node),
      path: [node | path.path],
      consumed: consumed,
      last: node
    }
  end

  defp visitable(node, path) do
    cond do
      node == "start" -> false
      String.upcase(node) == node -> true
      not MapSet.member?(path.nodes, node) -> true
      not path.consumed -> true
      true -> false
    end
  end
end

IO.puts(Paths.run("sample.txt") == 36)
IO.puts(Paths.run("sample2.txt") == 103)
IO.puts(Paths.run("sample3.txt") == 3509)
IO.puts(Paths.run("input.txt") == 119760)
