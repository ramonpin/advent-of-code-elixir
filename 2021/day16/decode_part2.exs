defmodule BITS do
  import Bitwise

  def decode(data) do
    data
    |> Base.decode16!()
    |> decode_packet()
    |> then(fn {_, value} -> value end)
  end

  def decode_packet(<<_version::3, rest::bits>>),
    do: decode_type(rest)

  ## type

  def decode_type(<<4::3, rest::bits>>), do: decode_literal(rest, 0)

  def decode_type(<<type::3, 0::1, len::15, subpackets::size(len)-bits, rest::bits>>) do
    {<<>>, subpackets_values} = decode_operator_len(subpackets, [])
    {rest, calc(type, subpackets_values)}
  end

  def decode_type(<<type::3, 1::1, count::11, rest::bits>>) do
    {rest, subpackets_values} = decode_operator_count(rest, count, [])
    {rest, calc(type, subpackets_values)}
  end

  ## literal

  def decode_literal(<<1::1, part::4, rest::bits>>, acc),
    do: decode_literal(rest, (acc <<< 4) + part)

  def decode_literal(<<0::1, part::4, rest::bits>>, acc),
    do: {rest, (acc <<< 4) + part}

  ## operator len

  def decode_operator_len(<<>>, values), do: {<<>>, values}

  def decode_operator_len(subpacket, values) do
    {subpacket, subpackages_values} = decode_packet(subpacket)
    decode_operator_len(subpacket, [subpackages_values | values])
  end

  ## operator count

  def decode_operator_count(rest, 0, values), do: {rest, values}

  def decode_operator_count(packets, count, values) do
    {rest, subpackets_values} = decode_packet(packets)
    decode_operator_count(rest, count - 1, [subpackets_values | values])
  end

  ## calc

  def calc(0, values), do: Enum.sum(values)
  def calc(1, values), do: Enum.product(values)
  def calc(2, values), do: Enum.min(values)
  def calc(3, values), do: Enum.max(values)
  def calc(5, [a, b]), do: if(b > a, do: 1, else: 0)
  def calc(6, [a, b]), do: if(b < a, do: 1, else: 0)
  def calc(7, [a, b]), do: if(a == b, do: 1, else: 0)
end

IO.puts(BITS.decode("C200B40A82") == 3)
IO.puts(BITS.decode("04005AC33890") == 54)
IO.puts(BITS.decode("880086C3E88112") == 7)
IO.puts(BITS.decode("CE00C43D881120") == 9)
IO.puts(BITS.decode("D8005AC2A8F0") == 1)
IO.puts(BITS.decode("F600BC2D8F") == 0)
IO.puts(BITS.decode("9C005AC2F8F0") == 0)
IO.puts(BITS.decode("9C0141080250320F1802104A08") == 1)

puzzle_input = File.read!("input.txt") |> String.trim()
IO.puts(BITS.decode(puzzle_input) == 18_234_816_469_452)
