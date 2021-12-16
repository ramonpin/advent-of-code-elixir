defmodule Submarine_Two do
  defstruct pos: 0, depth: 0, aim: 0

  def forward(%Submarine_Two{pos: pos, depth: depth, aim: aim} = submarine, n), 
    do: %{submarine | pos: pos + n, depth: depth + aim * n}

  def up(%Submarine_Two{aim: aim} = submarine, n),
    do: %{submarine | aim: aim - n} 

  def down(%Submarine_Two{aim: aim} = submarine, n),
    do: %{submarine | aim: aim + n} 
end

defmodule Dive_Two do
  def data(file) do
    File.stream!(file, mode: :line)
    |> Stream.map(&String.trim/1)
  end

  def run(file) do
    file
    |> data()
    |> Enum.reduce(%Submarine_Two{}, &execute_command/2)
    |> IO.inspect()
    |> calc_result()
  end

  def calc_result(%Submarine_Two{pos: pos, depth: depth}),
    do: pos * depth

  def execute_command("forward " <> n, sub),
    do: Submarine_Two.forward(sub, parse_int!(n))

  def execute_command("up " <> n, sub),
    do: Submarine_Two.up(sub, parse_int!(n))

  def execute_command("down " <> n, sub),
    do: Submarine_Two.down(sub, parse_int!(n))

  defp parse_int!(n) do
    case Integer.parse(n) do
      {n, ""} -> n
    end
  end
end
