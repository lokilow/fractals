defmodule Fractals.Components.Tiler do
  use Scenic.Component
  import Scenic.Primitives, only: [rect: 3]

  require Logger

  @impl Scenic.Component
  def validate({_upper_left, _lower_right} = coords), do: {:ok, coords}
  def validate(_), do: :invalid_data

  def graph(translate) do
    Scenic.Graph.build()
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        # top left
        |> rect({600, 600},
          id: "t00",
          translate: {0, 0},
          fill: {:stream, "t00"}
        )
        # top right
        |> rect({600, 600},
          id: "t10",
          translate: {600, 0},
          fill: {:stream, "t10"}
        )
        # # bottom left
        |> rect({600, 600},
          id: "t01",
          translate: {0, 600},
          fill: {:stream, "t01"}
        )
        # bottom right
        |> rect({600, 600},
          id: "t11",
          translate: {600, 600},
          fill: {:stream, "t11"}
        )
      end,
      translate: translate
    )
  end

  @impl Scenic.Scene
  def init(scene, {_size, translate}, _opts) do
    graph = graph(translate)

    {:ok, push_graph(scene, graph)}
  end
end
