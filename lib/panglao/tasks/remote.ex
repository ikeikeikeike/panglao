defmodule Panglao.Tasks.Remote do

  import Ecto.Query

  alias Panglao.{Repo, Object, ObjectUploader, Object.Basic, Tasks, Client.Progress}

  def perform do
    upload downloaded()
    upload Repo.all(from Object.with_downloaded, order_by: fragment("RANDOM()"), limit: 30)
  end

  defp downloaded do
    objects = Repo.all(from Object.with_download, order_by: fragment("RANDOM()"), limit: 30)

    Enum.map(objects, fn object ->
      with {:ok, %{body: %{"status" => "finished"}}} <- Progress.get(object.url),
           {:ok, object} <- Repo.update(Object.changeset(object, %{"stat" => "DOWNLOADED"})) do
        object
      else
        # {:ok, %{body: %{}}} ->
          # Repo.update!(Object.changeset(object, %{"stat" => "DOWNLOAD_FAILURE"}))
        _msg ->
          # IO.inspect msg
          :try_again
      end
    end)
    |> Enum.filter(fn
      %Object{stat: "DOWNLOADED"} -> true
      _ -> false
    end)
  end

  defp upload(objects) do
    src = fn object, binary ->
      %Plug.Upload{
        content_type: nil, filename: object.name,
        path: Panglao.File.store_temporary(binary),
      }
    end

    Enum.map objects, fn object ->
      with {:ok, binary} <- File.read(object.remote),
           {:ok, object} <- Basic.upload(object, %{"src" => src.(object, binary)}) do

        # Convert
        Exq.enqueue Exq, "encoder", Tasks.Encode, [object.id]

        # Make img and remove mp4
        ObjectUploader.local_url {object.src, object}
        File.rm object.remote
      else
        {:error, error} ->
          Repo.update Object.changeset(object, %{"stat" => "DOWNLOAD_FAILURE"})
          File.rm object.remote
          error
        error ->
          Repo.update Object.changeset(object, %{"stat" => "DOWNLOAD_FAILURE"})
          File.rm object.remote
          error
      end
    end
  end

end
