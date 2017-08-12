defmodule Panglao.Tasks.Remote2 do
  alias Panglao.{Repo, Object, Tasks, ObjectUploader, Client.Cheapcdn}

  require Logger

  @tries 50

  defp wait(count) when count >= 45 do
    sec = round :math.pow(count + 15, 2)
    :timer.sleep sec * 1000   # (X+15)**2 x 5 = 784 mins(5.34 hours)
  end
  defp wait(_count) do
    :timer.sleep 15_000       # 15 sec x 45 = around 10 ~ 40 mins
  end

  def perform(id) do
    resurrect()
    loop Repo.get(Object, id)
  end

  defp loop(object, count \\ 0)
  defp loop(%Object{id: id} = object, count)
       when is_integer(id) do

    case Cheapcdn.progress(object.url, object.remote) do
      {:ok, %{body: %{"status" => "finished"}}} ->
        if filename = remotefile(object) do
          succeed object, filename
        else
          wait count
          loop object, count + 3
        end

      {:ok, %{body: body}} when map_size(body) > 0 ->
        wait count
        loop object, count + Enum.random([0, 0, 0, 1])

      _msg ->
        if count > @tries do
          if filename = remotefile(object) do
            succeed object, filename
          else
            wrong object
          end
          :fetch_limited
        else
          wait count
          loop object, count + 1
        end
    end
  end
  defp loop(_, _), do: :does_not_exists

  defp rectify_remote(object, body) do
    if body["filename"] && object.remote != body["filename"] do
      params = %{"remote" => body["filename"]}
      Repo.update! Object.changeset(object, params)
    else
      object
    end
  end

  @excludes ~w(.jpg .jpeg .gif .png .JPG .m3u8 .mp3 .preview.mp4)
  defp remotefile(object) do
    with {:ok, %{body: %{"root" => file}}} when is_list(file) <- Cheapcdn.findfile(object.url, object.remote),
         file when length(file) > 0 <- Enum.filter(file, & not Enum.member?(@excludes, Path.extname(&1))) do
      List.first(file)
    else _ ->
      nil
    end
  end

  defp succeed(object, filename) do
    object = rectify_remote(object, %{"filename" => filename})
    object = pending object

    try do
      # Create image to filesystem
      ObjectUploader.local_url {object.src, object}
    rescue err ->
      Logger.warn("prepare make image: #{inspect err}")
    catch err ->
      Logger.warn("prepare make image: #{inspect err}")
    end

    # Convert
    # Exq.enqueue Exq, "encoder", Tasks.Encode, [object.id]
    Tasks.Encode.perform object.id
  end

  defp wrong(object) do
    params = %{"stat" => "WRONG"}
    Repo.update! Object.changeset(object, params)
  end

  defp pending(object) do
    params = %{"src" => Path.basename(object.remote)}
    Repo.update! Object.object_changeset(object, params)
  end

  defp resurrect do
    case Process.whereis(Repo) do
      pid when is_pid(pid) ->
        unless Process.alive?(pid),
          do: Repo.start_link
      _ ->
        Repo.start_link
    end
  end

end
