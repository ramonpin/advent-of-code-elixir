defmodule BITS do
  import Bitwise

  def decode(data) do
    data
    |> Base.decode16!()
    |> decode_packet([])
    |> then(fn {_, versions} -> Enum.sum(versions) end)
  end

  def decode_packet(<<version::3, rest::bits>>, versions),
    do: decode_type(rest, [version | versions])

  ## type

  def decode_type(<<4::3, rest::bits>>, versions) do
    {rest, _value} = decode_literal(rest, 0)
    {rest, versions}
  end

  def decode_type(<<_type::3, 0::1, len::15, subpackets::size(len)-bits, rest::bits>>, versions) do
    {<<>>, subpackets_versions} = decode_operator_len(subpackets, [])
    {rest, subpackets_versions ++ versions}
  end

  def decode_type(<<_type::3, 1::1, count::11, rest::bits>>, versions) do
    {rest, subpackets_versions} = decode_operator_count(rest, count, [])
    {rest, subpackets_versions ++ versions}
  end

  ## literal

  def decode_literal(<<1::1, part::4, rest::bits>>, acc),
    do: decode_literal(rest, (acc <<< 4) + part)

  def decode_literal(<<0::1, part::4, rest::bits>>, acc),
    do: {rest, (acc <<< 4) + part}

  ## operator len

  def decode_operator_len(<<>>, versions), do: {<<>>, versions}

  def decode_operator_len(subpacket, versions) do
    {subpacket, subpackages_versions} = decode_packet(subpacket, [])
    decode_operator_len(subpacket, subpackages_versions ++ versions)
  end

  ## operator count

  def decode_operator_count(rest, 0, versions), do: {rest, versions}

  def decode_operator_count(packets, count, versions) do
    {rest, subpackets_versions} = decode_packet(packets, [])
    decode_operator_count(rest, count - 1, subpackets_versions ++ versions)
  end
end

IO.puts(BITS.decode("38006F45291200") == 9)
IO.puts(BITS.decode("EE00D40C823060") == 14)
IO.puts(BITS.decode("8A004A801A8002F478") == 16)
IO.puts(BITS.decode("620080001611562C8802118E34") == 12)
IO.puts(BITS.decode("C0015000016115A2E0802F182340") == 23)
IO.puts(BITS.decode("A0016C880162017C3686B18A3D4780") == 31)

puzzle_input = File.read!("input.txt") |> String.trim()
IO.puts(BITS.decode(puzzle_input) == 986)
