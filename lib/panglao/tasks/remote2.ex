defmodule Panglao.Tasks.Remote2 do
  alias Panglao.{Repo, RepoReader, Object, Tasks, ObjectUploader, Client.Cheapcdn}

  require Logger

  @tries 50

  defp wait(count) when count >= 45 do
    :timer.sleep 1_200_000 # 20 min x 5 = 100 mins
  end
  defp wait(_count) do
    :timer.sleep 15_000   # 15 sec x 45 = around 10 ~ 110 mins
  end

  def perform(id) do
    loop RepoReader.gets(Object, id)
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

      {:ok, %{body: %{"status" => "crap"}}} ->
        wait count
        loop crap(object), count

      {:ok, %{body: body}} when map_size(body) > 0 ->
        wait count
        loop object, count + Enum.random([
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
        ])

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

  defp crap(%{stat: stat} = object) when stat != "CRAP" do
    params = %{"stat" => "CRAP"}
    Repo.update! Object.changeset(object, params)
  end
  defp crap(object), do: object

  defp pending(object) do
    params = %{"src" => Path.basename(object.remote)}
    Repo.update! Object.object_changeset(object, params)
  end
end
