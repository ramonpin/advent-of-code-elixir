defmodule MultiRange do
  defstruct components: []

  def new(),
    do: %MultiRange{}

  def new(ranges) when is_list(ranges),
    do: %MultiRange{components: ranges}

  def from_strings(strings) do
    strings
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.map(fn [a, b] -> String.to_integer(a)..String.to_integer(b) end)
    |> new()
  end

  def concat(%MultiRange{components: components1}, %MultiRange{components: components2}),
    do: %MultiRange{components: components1 ++ components2}

  def value_in(%MultiRange{components: components}, value),
    do:
      Enum.reduce_while(components, false, fn range, _ ->
        if value in range do
          {:halt, true}
        else
          {:cont, false}
        end
      end)
end

defmodule Ticket do
  alias MultiRange, as: MRange

  def nearby_tickets(file \\ "nearby.txt") do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&Enum.map(&1, fn num -> String.to_integer(num) end))
    |> Stream.map(&List.to_tuple/1)
  end

  def valid_values() do
    "fields.txt"
    |> fields_data()
    |> Enum.reduce(MRange.new(), fn {_field, mr}, acc -> MRange.concat(acc, mr) end)
  end

  def fields_data(file \\ "fields.txt") do
    file
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, ~r/: | or /) end)
    |> Enum.map(fn [field, range1, range2] -> {field, MRange.from_strings([range1, range2])} end)
    |> Map.new()
  end

  def valid?(ticket) do
    valid_values = valid_values()

    ticket
    |> Tuple.to_list()
    |> Enum.all?(&MRange.value_in(valid_values, &1))
  end

  def scanning_error_rate(tickets) do
    tickets
    |> Enum.map(&error/1)
    |> Enum.sum()
  end

  def error(ticket) do
    valid_values = valid_values()

    ticket
    |> Tuple.to_list()
    |> Enum.reduce_while(0, fn field, _ ->
      if MRange.value_in(valid_values, field) do
        {:cont, 0}
      else
        {:halt, field}
      end
    end)
  end

  def tickets_col_is_field?(tickets, col_num, field) do
    field_mrange = Map.get(fields_data(), field)

    tickets
    |> Enum.map(&elem(&1, col_num))
    |> Enum.all?(&MRange.value_in(field_mrange, &1))
  end

  def run do
    fields = fields_data()
    tickets = Enum.filter(nearby_tickets(), &(error(&1) == 0))

    relations =
      for field <- Map.keys(fields), col <- 0..19 do
        if tickets_col_is_field?(tickets, col, field) do
          {field, col}
        end
      end

    relations
    |> Enum.filter(& &1)
    |> Enum.group_by(&elem(&1, 1)) 
    |> Enum.map(fn {n, l} -> {n, length(l), MapSet.new(Enum.map(l, &elem(&1, 0)))} end) 
    |> Enum.sort_by(&elem(&1, 1)) 
    |> List.insert_at(0, {0, 0, MapSet.new()})
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [{_, _, s1}, {n, _, s2}] -> {n, MapSet.difference(s2, s1) |> MapSet.to_list()} end)
    |> Enum.sort()
  end
end
