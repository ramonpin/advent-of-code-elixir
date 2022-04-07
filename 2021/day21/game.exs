defmodule Game do
  defstruct players: [], dice: 1, rolls: 0, turn: 0

  def run(pos_1, pos_2) do
    Game.new(pos_1, pos_2)
    |> play()
    |> score()
  end

  def new(pos_1, pos_2), do: %Game{players: [{pos_1, 0}, {pos_2, 0}]}

  def step(game) do
    {roll, game} = roll(game)

    players =
      List.update_at(game.players, game.turn, fn {pos, score} ->
        pos = rem(pos + roll - 1, 10) + 1
        score = score + pos

        {pos, score}
      end)

    dice = rem(game.dice, 100) + 1
    turn = if game.turn == 0, do: 1, else: 0

    %Game{players: players, dice: dice, turn: turn, rolls: game.rolls + 3}
  end

  def roll(game) do
    [first_roll, second_roll, third_roll] =
      game.dice
      |> Stream.iterate(&(rem(&1, 10) + 1))
      |> Enum.take(3)

    {first_roll + second_roll + third_roll, %{game | dice: third_roll}}
  end

  def play(game) do
    game
    |> Stream.iterate(&step/1)
    |> Stream.drop_while(fn %{players: [{_, s1}, {_, s2}]} -> s1 < 1000 and s2 < 1000 end)
    |> Enum.at(0)
  end

  def score(%Game{players: [{_, s1}, {_, s2}], rolls: rolls}) do
    if s1 >= 1000 do
      s2 * rolls
    else
      s1 * rolls
    end
  end
end

IO.puts(Game.run(4, 8) == 739_785)
IO.puts(Game.run(8, 5) == 597_600)
