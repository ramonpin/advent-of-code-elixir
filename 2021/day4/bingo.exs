defmodule Board do
  defstruct rows: [], cols: []

  def read_boards(data) do
    data
    |> Enum.chunk_every(5)
    |> Enum.map(&chunk_to_board/1)
  end

  defp chunk_to_board(chunk) do
    chunk
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> then(fn rows -> %Board{rows: rows, cols: transpose(rows)} end)
  end

  defp transpose(cells) do
    for col <- 1..5, row <- 1..5 do
      cell_at(cells, row, col)
    end
    |> Enum.chunk_every(5)
  end

  defp cell_at(cells, row, col) do
    cells
    |> Enum.at(row - 1)
    |> Enum.at(col - 1)
  end

  def mark(%Board{} = board, num) do
    %Board{rows: markp(board.rows, num), cols: markp(board.cols, num)}
  end

  def winner(%Board{} = board) do
    Enum.any?(board.rows ++ board.cols, &(&1 == [:mark, :mark, :mark, :mark, :mark]))
  end

  def score(%Board{} = board) do
    for row <- board.rows, value <- row, reduce: 0 do
      acc ->
        case value do
          :mark -> acc
          value -> acc + String.to_integer(value)
        end
    end
  end

  defp markp(cells, num) do
    for row <- cells, value <- row do
      if value == num do
        :mark
      else
        value
      end
    end
    |> Enum.chunk_every(5)
  end
end

defmodule Bingo do
  def data(file) do
    {[random], boards} =
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.split(1)

    {String.split(random, ","), Board.read_boards(boards)}
  end

  def run_number(number, boards) do
    for board <- boards do
      Board.mark(board, number)
    end
  end

  def run_bingo({random, boards}) do
    {num, [board]} =
      Enum.reduce_while(random, boards, fn number, boards ->
        boards = run_number(number, boards)
        winner = Enum.filter(boards, &Board.winner/1)
        if winner != [], do: {:halt, {number, winner}}, else: {:cont, boards}
      end)

    String.to_integer(num) * Board.score(board)
  end

  def last_winner({random, boards}) do
    Enum.reduce_while(random, boards, fn number, boards ->
      boards = run_number(number, boards)
      boards = Enum.reject(boards, &Board.winner/1)
      if length(boards) == 1, do: {:halt, {random, boards}}, else: {:cont, boards}
    end)
  end

  def run(file) do
    file
    |> data()
    |> run_bingo()
  end

  def run_loose(file) do
    file
    |> data()
    |> last_winner()
    |> run_bingo()
  end
end
