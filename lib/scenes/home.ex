defmodule Fractals.Scene.Home do
  use Scenic.Scene
  require Logger

  @upper_left %{re: -2.05, im: 2.25}
  @lower_right %{re: 2.05, im: -2.75}
  @starting_coords {@upper_left, @lower_right}

  @graph [] |> Scenic.Graph.build()

  def graph(viewport, {_ul, _lr} = coords) do
    translate = {0, 0}

    @graph
    |> Fractals.Components.Tiler.add_to_graph({viewport.size, translate}, id: :tiler)
    |> Fractals.Components.Nav.add_to_graph(coords, id: :nav)
  end

  @impl true
  def init(scene, _param, _opts) do
    Fractals.TileServer.generate_tiles({@upper_left, @lower_right}, {2, 2})

    graph = graph(scene.viewport, {@upper_left, @lower_right})

    {:ok, scene |> assign(coords: @starting_coords) |> push_graph(graph)}
  end

  @impl true
  def handle_input(input, id, scene) do
    Logger.info("\n#{__MODULE__}: Handle Input\nInput: #{inspect(input)}\nId: #{inspect(id)}")
    {:noreply, scene}
  end

  @impl true
  def handle_event({:new_coords, coords}, _from, scene) do
    if coords != scene.assigns.coords do
      Logger.info("#{__MODULE__}: Updating Coords!\nNew Coords: #{inspect(coords)}")

      graph = graph(scene.viewport, coords)

      {:noreply, scene |> assign(coords: coords) |> push_graph(graph)}
    else
      {:noreply, scene}
    end
  end

  def handle_event(event, from, scene) do
    Logger.info("\n#{__MODULE__}: Handle Event\nEvent: #{inspect(event)}\nFrom: #{inspect(from)}")
    {:noreply, scene}
  end
end
