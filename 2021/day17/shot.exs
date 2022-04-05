defmodule Shot do
  defmodule Probe do
    defstruct x: 0, y: 0, vx: 0, vy: 0, max_y: 0, status: :continue
  end

  def run(vx, vy) do
    %Probe{vx: vx, vy: vy}
    |> Stream.iterate(&step/1)
    |> Stream.map(&hit_or_miss(&1, {20, 30, -5, -10}))
    |> Stream.reject(fn probe -> probe.status == :continue end)
    |> Enum.take(1)
  end

  defp hit_or_miss(%Probe{} = probe, {x1, x2, y1, y2}) do
    status =
      cond do
        probe.x > x2 or probe.y < y2 -> :miss
        probe.x >= x1 and probe.y <= y1 -> :hit
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
