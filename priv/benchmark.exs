require Logger

function_iterations = 1
bounds = {%{re: -2.0, im: 2.0}, %{re: 2.0, im: -2.0}}

benchmarks = %{
  "mandelbrot" => fn ->
    for _ <- 0..function_iterations,
        do: Fractals.Generate.generate({1000, 1000}, bounds)
  end
}

title = "Parallel-Rayon"

Benchee.run(
  benchmarks,
  _config = [
    formatters: [
      {Benchee.Formatters.JSON, file: "benchmarks/#{title}.json"},
      Benchee.Formatters.Console
    ],
    title: title
  ]
)
