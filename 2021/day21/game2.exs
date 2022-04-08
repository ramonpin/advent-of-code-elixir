defmodule Game do
  @dice %{3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1}

  defstruct players: [], turn: 0, universes: 1

  def new(pos_1, pos_2), do: %Game{players: [{pos_1, 0}, {pos_2, 0}]}

  def step(game, {roll, universes}) do
    players =
      List.update_at(game.players, game.turn, fn {pos, score} ->
        pos = rem(pos + roll - 1, 10) + 1
        score = score + pos

        {pos, score}
      end)

    turn = if game.turn == 0, do: 1, else: 0

    %Game{
      players: players,
      turn: turn,
      universes: game.universes * universes
    }
  end

  def consolidate_games(games) do
    Enum.reduce(games, fn game, acc -> %{acc | universes: acc.universes + game.universes} end)
  end

  def play_single(game) do
    Enum.map(@dice, fn die -> step(game, die) end)
  end

  def play({games, wins_1, wins_2}) do
    {games, wins_1, wins_2} =
      games
      |> Enum.flat_map(&play_single/1)
      |> Enum.group_by(fn game -> {game.players, game.turn} end)
      |> Enum.map(fn {_, games} -> consolidate_games(games) end)
      |> Enum.reduce({[], wins_1, wins_2}, fn game, {games, wins_1, wins_2} ->
        case game do
          %Game{players: [{_, s1}, {_, s2}]} ->
            cond do
              s1 >= 21 -> {games, wins_1 + game.universes, wins_2}
              s2 >= 21 -> {games, wins_1, wins_2 + game.universes}
              true -> {[game | games], wins_1, wins_2}
            end
        end
      end)

    if games == [] do
      {wins_1, wins_2}
    else
      play({games, wins_1, wins_2})
    end
  end

  def run(pos_1, pos_2) do
    play({[Game.new(pos_1, pos_2)], 0, 0})
  end
end

IO.puts(Game.run(4, 8) == {444_356_092_776_315, 341_960_390_180_808})
IO.inspect(Game.run(8, 5) == {634_769_613_696_613, 382_487_451_335_154})
