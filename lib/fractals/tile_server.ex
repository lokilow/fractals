defmodule Fractals.TileServer do
  alias Scenic.Assets.Stream

  def generate_tiles({upper_left, lower_right}, {rows, cols}) do
    tile_width = (lower_right.re - upper_left.re) / cols
    tile_height = (upper_left.im - lower_right.im) / rows

    for row <- 0..(rows - 1), col <- 0..(cols - 1) do
      upper_left = %{re: upper_left.re + tile_width * col, im: upper_left.im - tile_height * row}
      lower_right = %{re: upper_left.re + tile_width, im: upper_left.im - tile_height}

      bin =
        Fractals.Generate.generate({600, 600}, {upper_left, lower_right}) |> :binary.list_to_bin()

      {:ok, img} = Stream.Image.from_binary(bin)
      Stream.put("t#{col}#{row}", img)
    end
  end
end
