require Logger
function_iterations = 1

benchmarks = %{
  "mandelbrot" => fn ->
    for _ <- 0..function_iterations, do: Fractals.Generate.generate({1000, 1000})
  end
}

max_cores = :erlang.system_info(:logical_processors_available)
Logger.info("max cores: #{max_cores}")

runs = [1, 2] |> Enum.concat(4..max_cores//4) |> Enum.take_while(&(&1 <= max_cores))

for num_cores <- runs do
  title = "Parallel - Cores: #{num_cores}"

  Benchee.run(
    benchmarks,
    _config = [
      formatters: [
        {Benchee.Formatters.JSON, file: "benchmarks/parallel-cores:#{num_cores}.json"},
        Benchee.Formatters.Console
      ],
      title: title,
      parallel: num_cores
    ]
  )
end
