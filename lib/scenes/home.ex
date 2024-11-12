defmodule Fractals.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Scenic.Assets.Stream

  import Scenic.Primitives

  @text_size 18
  @upper_left %{re: -2.5, im: 1.7}
  @lower_right %{re: 1.5, im: -1.7}

  @graph Graph.build(font: :roboto, font_size: @text_size)
         |> add_specs_to_graph([
           # this is a placeholder for the navbar
           rect_spec({1600, 1200}, fill: {:stream, "fractal"})
         ])
         |> Fractals.Components.Nav.add_to_graph({@upper_left, @lower_right})

  ## TODO
  ## The UI should have a nav bar that appears on click of a gear. Initially, show parameters for mandelbrot generation, and a generate button.
  ## When generating show a loading icon.
  ## create a navigation panel that zooms in and scrolls up/left/down/etc
  ## should also show x/y coordinates
  def init(scene, _param, _opts) do
    bin = Fractals.Generate.generate() |> :binary.list_to_bin()
    {:ok, img} = Stream.Image.from_binary(bin)
    Stream.put("fractal", img)
    scene = push_graph(scene, @graph)

    {:ok, scene}
  end

  def handle_input(event, _context, scene) do
    Logger.info("Handle Input: #{inspect(event)}")
    {:noreply, scene}
  end

  def handle_event({:click, :regenerate}, _context, scene) do
    nil
    |> Fractals.Generate.generate(
      %{
        re: :rand.uniform() * -1,
        im: :rand.uniform()
      },
      %{
        re: :rand.uniform(),
        im: :rand.uniform() * -1
      }
    )
    |> :binary.list_to_bin()
    |> Stream.Image.from_binary()
    |> then(fn {:ok, bin} -> Stream.put("fractal", bin) end)

    {:noreply, scene}
  end

  def handle_event(event, _context, scene) do
    Logger.info("Handle Event: #{inspect(event)}")
    {:noreply, scene}
  end
end
