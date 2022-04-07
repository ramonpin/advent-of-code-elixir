defmodule Fold.Data do
  def parse(file) do
    {holes, [_ | instructions]} =
      file
      |> File.stream!(mode: :line)
      |> Enum.map(&String.trim/1)
      |> Enum.split_while(fn line -> line != "" end)

    {
      MapSet.new(holes, &parse_coords/1),
      Enum.map(instructions, &parse_instruction/1)
    }
  end

  def print(holes), do: IO.puts(holes_str(holes))

  defp holes_str(holes) do
    {max_x, max_y} =
      Enum.reduce(holes, {0, 0}, fn {x, y}, {max_x, max_y} ->
        {max(x, max_x), max(y, max_y)}
      end)

    for y <- 0..max_y, x <- 0..max_x, into: "" do
      jump = if x == max_x, do: "\n", else: ""

      if MapSet.member?(holes, {x, y}) do
        "#" <> jump
      else
        "." <> jump
      end
    end
  end

  defp parse_coords(coords_str) do
    coords_str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> then(fn [a, b] -> {a, b} end)
  end

  defp parse_instruction("fold along " <> instruction) do
    [axis, point] = String.split(instruction, "=")

    {axis, String.to_integer(point)}
  end
end

defmodule Fold do
  defdelegate data(file), to: Fold.Data, as: :parse
  defdelegate print(holes), to: Fold.Data

  # PART - 2
  def run(file) do
    {holes, instructions} = data(file)

    instructions
    |> Enum.reduce(holes, &fold/2)
    |> print()
  end

  # PART - 1
  def first_fold(file) do
    {holes, [first | _]} = data(file)

    first
    |> fold(holes)
    |> MapSet.size()
  end

  def fold({"y", row}, holes) do
    for {x, y} <- holes, reduce: MapSet.new() do
      new_holes ->
        cond do
          y > row ->
            MapSet.put(new_holes, {x, y - 2 * (y - row)})

          true ->
            MapSet.put(new_holes, {x, y})
        end
    end
  end

  def fold({"x", col}, holes) do
    for {x, y} <- holes, reduce: MapSet.new() do
      new_holes ->
        cond do
          x > col ->
            MapSet.put(new_holes, {x - 2 * (x - col), y})

          true ->
            MapSet.put(new_holes, {x, y})
        end
    end
  end
end

IO.puts(Fold.first_fold("sample.txt") == 17)
Fold.run("sample.txt")

IO.puts(Fold.first_fold("input.txt") == 788)
Fold.run("input.txt")
