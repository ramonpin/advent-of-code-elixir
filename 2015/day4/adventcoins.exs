defmodule AdventCoins do
  def mine(key) do
    1
    |> Stream.iterate(&(&1 + 1))
    |> Stream.filter(fn n -> hash(key, n) |> valid_hash() end)
    |> Enum.take(1)
    |> List.first()
  end

  def hash(key, val) do
    key <> Integer.to_string(val)
    |> then(&:crypto.hash(:md5, &1))
    |> Base.encode16()
  end

  def valid_hash("000000" <> _), do: true
  def valid_hash(_), do: false
end
