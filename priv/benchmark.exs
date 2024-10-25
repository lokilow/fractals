require Logger
function_iterations = 1
save_dir = "benchmark_results/"

benchmarks = %{
  "mandelbrot" => fn -> for _ <- 0..function_iterations, do: Fractals.Generate.generate() end
}

max_cores = :erlang.system_info(:logical_processors_available)
Logger.info("max cores: #{max_cores}")

runs = [1, 2] |> Enum.concat(4..max_cores//4) |> Enum.take_while(&(&1 <= max_cores))

for num_cores <- runs do
  title = "Cores: #{num_cores}"

  Benchee.run(
    benchmarks,
    config = [
      formatters: [
        {Benchee.Formatters.JSON, file: "benchmarks/cores:#{num_cores}.json"},
        Benchee.Formatters.Console
      ],
      title: title,
      parallel: num_cores
    ]
  )
end
