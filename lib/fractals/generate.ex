defmodule Fractals.Generate do
  defmodule Nif do
    use Rustler, otp_app: :fractals, crate: "fractals", path: "."

    def generate({_width, _height}, _upper_left, _lower_right),
      do: :erlang.nif_error(:nif_not_loaded)
  end

  def generate(image_size \\ nil, {upper_left, lower_right}) do
    {width, height} =
      if image_size do
        image_size
      else
        Application.get_env(:fractals, :viewport)[:size]
      end

    Nif.generate({width, height}, upper_left, lower_right)
  end
end
