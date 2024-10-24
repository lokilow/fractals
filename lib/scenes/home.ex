defmodule Fractals.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Scenic.Assets.Stream

  import Scenic.Primitives

  @text_size 18

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
        rect_spec({width, height + 50}, translate: {0, 50}, fill: {:stream, "fractal"})
      ])

    scene = push_graph(scene, graph)

    {:ok, scene}
  end

  def handle_input(event, _context, scene) do
    Logger.info("Received event: #{inspect(event)}")
    {:noreply, scene}
  end
end
