defmodule Diagnostic do
  def power_consumption(file) do
    file
    |> data()
    |> combine([&gamma_rate/1, &epsilon_rate/1])
    |> Enum.product()
  end

  def life_support_rating(file) do
    file
    |> data()
    |> combine([&oxygen_generator_rating/1, &co2_scrubber_rating/1])
    |> Enum.product()
  end

  def data(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Enum.map(&String.to_char_list/1)
  end

  def gamma_rate(data),
    do: rate(data, &gamma/2)

  def epsilon_rate(data),
    do: rate(data, &epsilon/2)

  def gamma(zeros, ones),
    do: length(zeros) > length(ones)

  def epsilon(zeros, ones),
    do: length(zeros) <= length(ones)

  def oxygen_generator_rating(data),
    do: gas_generator_rating(data, 0, &gamma/2)

  def co2_scrubber_rating(data),
    do: gas_generator_rating(data, 0, &epsilon/2)

  defp gas_generator_rating([result], _, _) do
    result
    |> List.to_string()
    |> Integer.parse(2)
    |> then(fn {num, ""} -> num end)
  end

  defp gas_generator_rating(data, column, check) do
    most_common_bit = ?0 + bits_cols(data, column, check)
    new_data = Enum.filter(data, &(Enum.at(&1, column) == most_common_bit))
    gas_generator_rating(new_data, column + 1, check)
  end

  defp rate(data, func) do
    data
    |> columns()
    |> Enum.map(&bits_cols(data, &1, func))
    |> Integer.undigits(2)
  end

  def bits_cols(data, column, check) do
    data
    |> Stream.map(&Enum.at(&1, column))
    |> Enum.group_by(& &1)
    |> then(fn
      %{?0 => zeros, ?1 => ones} -> if check.(zeros, ones), do: 0, else: 1
      %{?0 => _} -> 0
      %{?1 => _} -> 1
    end)
  end

  defp columns(data) do
    0..(length(Enum.at(data, 0)) - 1)
  end

  defp combine(data, funcs),
  do: Enum.map(funcs, fn func -> func.(data) end)
end
