defmodule Parse do 

  def rules(file) do
    file
    |> File.stream!(mode: :line)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " -> "))
    |> Map.new(fn [pair, new] -> 
      {to_charlist(pair), to_charlist(String.at(pair, 0) <> new)} 
    end)
  end

end
