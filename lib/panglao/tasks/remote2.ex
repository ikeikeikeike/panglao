defmodule Panglao.Tasks.Remote2 do
  alias Panglao.{Repo, Object, Tasks, ObjectUploader, Client.Cheapcdn}

  require Logger

  @tries 100

  defp wait do
    :timer.sleep 15_000  # 15 sec
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

          # Convert
          Exq.enqueue Exq, "encoder", Tasks.Encode, [object.id]

          # Make img and remove mp4
          ObjectUploader.local_url {object.src, object}

        else
          wait()
          loop object, count + 1
        end

      {:ok, %{body: body}} when map_size(body) > 0 ->
        rectify_remote object, body
        wait()
        loop object, count

      _msg ->
        if count > @tries do
          if filename = remotefile(object) do
            pending rectify_remote(object, %{"filename" => filename})
          else
            wrong object
          end
          :fetch_limited
        else
          wait()
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

  @excludes ~w(.jpg .jpeg .gif .png .JPG)
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
