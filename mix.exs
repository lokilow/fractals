defmodule Fractals.MixProject do
  use Mix.Project

  def project do
    [
      app: :fractals,
      version: "0.1.0",
      elixir: "~> 1.9",
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Fractals, []},
      extra_applications: [:crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev},
      {:benchee_json, "~> 1.0", only: :dev},
      {:rustler, "~> 0.35.0", runtime: false},
      {:scenic, "~> 0.11.0"},
      {:scenic_driver_local, "~> 0.11.0"}
    ]
  end

  defp aliases do
    [bench: ["run priv/benchmark.exs --no-start"]]
  end
end
