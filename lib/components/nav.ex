defmodule Fractals.Components.Nav do
  use Scenic.Component
  import Scenic.Components, only: [button: 3]
  require Logger

  @translate_coefficent 0.05
  @zoom_coefficient 0.1

  @impl true
  def validate({_upper_left, _lower_right} = coords), do: {:ok, coords}
  def validate(_), do: :invalid_data

  @impl true
  def init(scene, coords, _opts) do
    # modify the already built graph
    buttons =
      Enum.zip(
        [:up, :left, :right, :down, :out, :in],
        [{100, 100}, {50, 145}, {150, 145}, {100, 190}, {70, 235}, {160, 235}]
      )

    graph =
      Enum.reduce(buttons, Scenic.Graph.build(), fn {id, translate}, graph ->
        button(
          graph,
          button_text(id),
          id: id,
          translate: translate,
          # Button Style
          text_align: :center,
          width: button_width(id),
          height: 30
        )
      end)

    {:ok,
     scene
     |> assign(graph: graph)
     |> assign(coords: coords)
     |> push_graph(graph)}
  end

  # Don't think any input is wired up
  @impl true
  def handle_input(input, id, scene) do
    Logger.info("\n#{__MODULE__}: Handle Input\nInput: #{inspect(input)}\nId: #{inspect(id)}}")
    {:noreply, scene}
  end

  # The component receives input events from the parent scene
  @impl true
  def handle_event({:click, transform} = event, from, scene) do
    Logger.info(
      "\n#{__MODULE__}: Handle Event\nEvent: #{inspect(event)}\nFrom: #{inspect(from)}}"
    )

    coords = transform_coords(scene.assigns.coords, transform)
    :ok = send_parent_event(scene, {:new_coords, coords})

    {:noreply, scene}
  end

  def handle_event(event, from, _scene) do
    Logger.info(
      "\n#{__MODULE__}: Handle Event\nEvent: #{inspect(event)}\nFrom: #{inspect(from)}}"
    )
  end

  defp button_text(:in), do: "(+)"
  defp button_text(:out), do: "(-)"
  defp button_text(id), do: id |> Atom.to_string() |> String.capitalize()

  defp button_width(zoom) when zoom in [:in, :out], do: 50
  defp button_width(_direction), do: 80

  defp transform_coords(coords, transform) do
    {upper_left, lower_right} = coords

    case transform do
      :left ->
        shift = shift_width(coords)
        {%{upper_left | re: upper_left.re - shift}, %{lower_right | re: lower_right.re - shift}}

      :right ->
        shift = shift_width(coords)
        {%{upper_left | re: upper_left.re + shift}, %{lower_right | re: lower_right.re + shift}}

      :up ->
        shift = shift_height(coords)
        {%{upper_left | im: upper_left.im + shift}, %{lower_right | im: lower_right.im + shift}}

      :down ->
        shift = shift_height(coords)
        {%{upper_left | im: upper_left.im - shift}, %{lower_right | im: lower_right.im - shift}}

      :in ->
        width = lower_right.re - upper_left.re
        height = upper_left.im - lower_right.im
        new_width = width * (1 - @zoom_coefficient)
        new_height = height * (1 - @zoom_coefficient)
        height_diff = (height - new_height) / 2
        width_diff = (width - new_width) / 2

        {%{re: upper_left.re + width_diff, im: upper_left.im - height_diff},
         %{re: lower_right.re - width_diff, im: lower_right.im + height_diff}}

      :out ->
        width = lower_right.re - upper_left.re
        height = upper_left.im - lower_right.im
        new_width = width / (1 - @zoom_coefficient)
        new_height = height / (1 - @zoom_coefficient)
        height_diff = (new_height - height) / 2
        width_diff = (new_width - width) / 2

        {%{re: upper_left.re - width_diff, im: upper_left.im + height_diff},
         %{re: lower_right.re + width_diff, im: lower_right.im - height_diff}}
    end
  end

  defp shift_width({upper_left, lower_right}) do
    width = lower_right.re - upper_left.re
    width * @translate_coefficent
  end

  defp shift_height({upper_left, lower_right}) do
    height = upper_left.im - lower_right.im
    height * @translate_coefficent
  end
end
