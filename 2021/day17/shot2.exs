defmodule Shot do
  defmodule Probe do
    defstruct x: 0, y: 0, vx: 0, vy: 0, max_y: 0, status: :continue
  end

  def run(box) do
    {_, x_max, _, y_min} = box
    {x_dub_max, y_dub_max} = {2 * x_max, 2 * abs(y_min)}

    # The velocity limits are totaly an educated guess
    # no physics behind this, just brute force
    for vx <- 0..x_dub_max,
        vy <- -y_dub_max..y_dub_max,
        trial = launch(vx, vy, box),
        trial.status == :hit do
      trial
    end
  end

  def launch(vx, vy, box) do
    %Probe{vx: vx, vy: vy}
    |> Stream.iterate(&step/1)
    |> Stream.map(&hit_or_miss(&1, box))
    |> Stream.reject(fn probe -> probe.status == :continue end)
    |> Enum.at(0)
  end

  defp hit_or_miss(%Probe{} = probe, {x_min, x_max, y_max, y_min}) do
    status =
      cond do
        probe.x > x_max or probe.y < y_min -> :miss
        probe.x >= x_min and probe.y <= y_max -> :hit
        true -> :continue
      end

    %{probe | status: status}
  end

  defp step(%Probe{} = probe) do
    x = probe.x + probe.vx
    y = probe.y + probe.vy
    vx = probe.vx + drag(probe.vx)
    vy = probe.vy - 1
    max_y = Enum.max([probe.max_y, y])

    %Probe{x: x, y: y, vx: vx, vy: vy, max_y: max_y}
  end

  defp drag(n) do
    cond do
      n > 0 -> -1
      n < 0 -> 1
      true -> 0
    end
  end
end

shots = Shot.run({20, 30, -5, -10})
IO.puts(length(shots) == 112)

shots = Shot.run({70, 96, -124, -179})
IO.puts(length(shots) == 2555)
