defmodule Panglao.Tasks.Remote2 do
  alias Panglao.{Repo, Object, Tasks, ObjectUploader, Client.Cheapcdn}

  require Logger

  @tries 200

  defp wait(count) when count < 100 do
    :timer.sleep 15_000         # 15 sec x 100 = 25 min
  end

  defp wait(count) do
    :timer.sleep count * 1000   # count(100~200) sec x 100 = 250 min
  end

  def perform(id) do
    loop Repo.get(Object, id)
  end

  defp loop(object, count \\ 0)
  defp loop(%Object{id: id} = object, count)
       when is_integer(id) do

    case Cheapcdn.progress(object.remote) do
      {:ok, %{body: %{"status" => "finished"}}} ->
        if filename = remotefile(object) do
          object = rectify_remote(object, %{"filename" => filename})
          object = pending object

          # Make img and remove mp4
          ObjectUploader.local_url {object.src, object}

          :timer.sleep 5_000

          # Convert
          Exq.enqueue Exq, "encoder", Tasks.Encode, [object.id]

        else
          wait count
          loop object, count + 10
        end

      {:ok, %{body: body}} when map_size(body) > 0 ->
        wait count
        loop object, count + 1

      _msg ->
        if count > @tries do
          if filename = remotefile(object) do
            pending rectify_remote(object, %{"filename" => filename})
          else
            wrong object
          end
          :fetch_limited
        else
          wait count
          loop object, count + 5
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

  @excludes ~w(.jpg .jpeg .gif .png .JPG .m3u8)
  defp remotefile(object) do
    with {:ok, %{body: %{"file" => file}}} when is_list(file) <- Cheapcdn.findfile(object.remote),
         file when length(file) > 0 <- Enum.filter(file, & not Enum.member?(@excludes, Path.extname(&1))) do
      List.first(file)
    else _ ->
      nil
    end
  end

  defp wrong(object) do
    params = %{"stat" => "WRONG"}
    Repo.update! Object.changeset(object, params)
  end

  defp pending(object) do
    params = %{"src" => Path.basename(object.remote)}
    Repo.update! Object.object_changeset(object, params)
  end

end
