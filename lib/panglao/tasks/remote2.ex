defmodule Panglao.Tasks.Remote2 do
  alias Panglao.{Repo, Object, Tasks, ObjectUploader, Client.Progress, Client.Findfile}

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

    case Progress.progress(object.remote) do
      {:ok, %{body: %{"status" => "finished"} = body}} ->

        object = object |> rectify_remote(body) |> evolve_src()
        object = pending object

        # Convert
        Exq.enqueue Exq, "encoder", Tasks.Encode, [object.id]

        # Make img and remove mp4
        ObjectUploader.local_url {object.src, object}

      {:ok, %{body: body}} when map_size(body) > 0 ->
        rectify_remote object, body
        wait()
        loop object, count

      _msg ->
        if count > @tries do
          if evolve_src(object) do
            pending object
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
  defp evolve_src(object) do
    with {:ok, %{body: %{"file" => file}}} when is_list(file) <- Findfile.findfile(object.remote),
         file when length(file) > 0 <- Enum.filter(file, & not Enum.member?(@excludes, Path.extname(&1))) do

      rectify_remote(object, %{"filename" => List.first(file)})
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
