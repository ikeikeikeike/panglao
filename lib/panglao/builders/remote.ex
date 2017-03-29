defmodule Panglao.Builders.Remote do

  alias Panglao.{Repo, Object, Object.Basic, Builders, Client.Progress}

  def perform do
    upload downloaded()
    upload Repo.all(Object.with_downloaded)
  end

  defp downloaded do
    objects = Repo.all Object.with_download

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
        Exq.enqueue Exq, "encoder", Builders.Encode, [object.id]
      else
        {:error, error} ->
          error
      end
    end
  end

end
