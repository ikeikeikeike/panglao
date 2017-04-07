defmodule Panglao.Tasks.Remote do

  import Ecto.Query

  alias Panglao.{Repo, Object, Object.Basic, Tasks, Client.Progress}

  def perform do
    upload downloaded()
    upload Repo.all(from Object.with_downloaded, order_by: fragment("RANDOM()"))
  end

  defp downloaded do
    objects = Repo.all(from Object.with_download, order_by: fragment("RANDOM()"))

    Enum.map(objects, fn object ->
      with {:ok, %{body: %{"status" => "finished"}}} <- Progress.get(object.remote),
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
        Exq.enqueue Exq, "encoder", Tasks.Encode, [object.id]
      else
        {:error, error} ->
          Repo.update Object.changeset(object, %{"stat" => "DOWNLOAD_FAILURE"})
          error
        error ->
          Repo.update Object.changeset(object, %{"stat" => "DOWNLOAD_FAILURE"})
          error
      end
    end
  end

end
