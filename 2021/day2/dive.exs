defmodule Submarine do
  defstruct pos: 0, depth: 0

  def forward(submarine, n),
    do: Map.update!(submarine, :pos, fn pos -> pos + n end)

  def up(submarine, n),
    do: Map.update!(submarine, :depth, fn depth -> depth - n end)

  def down(submarine, n),
    do: Map.update!(submarine, :depth, fn depth -> depth + n end)
end

defmodule Dive do
  def data(file) do
    File.stream!(file, mode: :line)
    |> Stream.map(&String.trim/1)
  end

  def run(file) do
    file
    |> data()
    |> Enum.reduce(%Submarine{}, &execute_command/2)
    |> IO.inspect()
    |> calc_result()
  end

  def calc_result(%Submarine{pos: pos, depth: depth}),
    do: pos * depth

  def execute_command("forward " <> n, sub),
    do: Submarine.forward(sub, parse_int!(n))

  def execute_command("up " <> n, sub),
    do: Submarine.up(sub, parse_int!(n))

  def execute_command("down " <> n, sub),
    do: Submarine.down(sub, parse_int!(n))

  defp parse_int!(n) do
    case Integer.parse(n) do
      {n, ""} -> n
    end
  end
end
