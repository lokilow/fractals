require Logger
# get main viewport
mv = fn ->
  {:ok, vp} = Scenic.ViewPort.info(:main_viewport)
  vp
end

# reload main viewport
rl = fn ->
  recompile()
  vp = mv.()
  :ok = Scenic.ViewPort.set_theme(vp, :dark)
end

# restart app
rs =
  fn ->
    recompile()

    try do
      exit(:restart)
    catch
      :exit, :restart ->
        :ok = Logger.debug("Restarting App")
    end
  end
