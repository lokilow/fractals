defmodule Fractals.Generate do
  use Rustler, otp_app: :fractals, crate: "fractals"

  def generate(), do: :erlang.nif_error(:nif_not_loaded)
end
