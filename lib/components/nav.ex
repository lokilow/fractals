defmodule Fractals.Components.Nav do
  use Scenic.Component
  import Scenic.Components, only: [button: 3]

  def validate({_upper_left, _lower_right} = coords), do: {:ok, coords}
  def validate(_), do: :invalid_data

  def init(scene, _text, _opts) do
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
          width: width(id),
          height: 30
        )
      end)

    {:ok,
     scene
     |> assign(graph: graph)
     |> push_graph(graph)}
  end

  defp button_text(:in), do: "(+)"
  defp button_text(:out), do: "(-)"
  defp button_text(id), do: id |> Atom.to_string() |> String.capitalize()

  defp width(zoom) when zoom in [:in, :out], do: 50
  defp width(_direction), do: 80
end
