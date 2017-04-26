defmodule Panglao.Tasks.Remote do

  import Ecto.Query

  alias Panglao.{Repo, Object, ObjectUploader, Object.Basic, Tasks, Client.Progress}

  require Logger

  @limit_size 512 * 1024 * 1024

  def perform do
    upload uploading(downloaded())
    upload uploading(Repo.all(from Object.with_downloaded, order_by: fragment("RANDOM()"), limit: 10))
  end

  defp downloaded do
    objects = Repo.all(from Object.with_download, order_by: fragment("RANDOM()"), limit: 10)

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
      try do
        with {:ok, binary} <- File.read(object.remote),
             {:ok, %{size: size}} when size < @limit_size <- File.stat(object.remote),
             {:ok, object} <- Basic.upload(object, %{"src" => src.(object, binary)}) do

          # Convert
          Exq.enqueue Exq, "encoder", Tasks.Encode, [object.id]

          # Make img and remove mp4
          ObjectUploader.local_url {object.src, object}
          File.rm object.remote
        else
          {:error, error} ->
            Logger.warn "#{error}: #{object.id}"
            failure object
            error

          {:ok, %{size: _size}} ->
            Logger.warn "maxsize: #{object.id}"
            filemaxsize object
            :filemaxsize

          error ->
            Logger.warn "last #{error}: #{object.id}"
            failure object
            error
        end
      rescue error ->
        Logger.error "rescue #{error}: #{object.id}"
        failure object
        error

      catch error ->
        Logger.error "catch #{error}: #{object.id}"
        failure object
        error
      end
    end
  end

  defp uploading(objects) when is_list(objects) do
    upfiles =
      Enum.map objects, fn object ->
        case uploading(object) do
          {:ok,   object} -> object
          {:error, error} -> Logger.warn error
        end
      end

    Enum.filter upfiles, fn
      %Object{} -> true
      _         -> false
    end
  end

  defp uploading(object) do
    Repo.update Object.changeset(object, %{"stat" => "UPLOADING"})
  end

  defp failure(object) do
    Repo.update Object.changeset(object, %{"stat" => "DOWNLOAD_FAILURE"})
    File.rm object.remote
  end

  defp filemaxsize(object) do
    Repo.update Object.changeset(object, %{"stat" => "DOWNLOAD_FILEMAXSIZE"})
    File.rm object.remote
  end

end
