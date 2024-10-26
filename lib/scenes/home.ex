defmodule Fractals.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Scenic.Assets.Stream

  import Scenic.Primitives
  import Scenic.Components

  @text_size 18

  ## TODO
  ## The UI should have a nav bar that appears on click of a gear. Initially, show parameters for mandelbrot generation, and a generate button.
  ## When generating show a loading icon.
  ## create a navigation panel that zooms in and scrolls up/left/down/etc
  ## should also show x/y coordinates
  def init(scene, _param, _opts) do
    # get the width and height of the viewport. This is to demonstrate creating
    # a transparent full-screen rectangle to catch user input
    {width, height} = scene.viewport.size

    bin = Fractals.Generate.generate() |> :binary.list_to_bin()
    {:ok, img} = Stream.Image.from_binary(bin)
    Stream.put("fractal", img)

    graph =
      Graph.build(font: :roboto, font_size: @text_size)
      |> add_specs_to_graph([
        # this is a placeholder for the navbar
        rect_spec({width, height + 50}, translate: {0, 50}, fill: {:stream, "fractal"})
      ])
      |> button("Regenerate", id: :generate)

    scene = push_graph(scene, graph)

    {:ok, scene}
  end

  def handle_input(event, _context, scene) do
    Logger.info("Handle Input: #{inspect(event)}")
    {:noreply, scene}
  end

  def handle_event(event, _context, scene) do
    Logger.info("Handle Event: #{inspect(event)}")
    {:noreply, scene}
  end
end
