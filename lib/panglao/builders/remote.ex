defmodule Panglao.Builders.Remote do
  import Panglao.Builders.Base
  import Ecto.Query, only: [from: 2]

  alias Panglao.{Repo, Object, Object.Basic, Builders, Client.Progress}

  def perform do
    Repo.transaction fn ->
      Enum.each downloaded(), fn object ->
        src = %Plug.Upload{path: object.remote, filename: object.name}

        Basic.upload(object, %{"src" => src})
        |> case do
          {:ok, object} ->
            Exq.enqueue Exq, "encoder", Builders.Encode, [object.id]

          {:error, changeset} ->
            Repo.rollback changeset
          end
      end
    end
  end

  defp downloaded do
    objects = Repo.all from(q in Object.with_remote, where: q.stat == "DOWNLOAD")

    Enum.map(objects, fn object ->
      with {:ok, %{body: %{"status" => "finished"}}} <- Progress.get(object.remote),
           {:ok, object} <- Repo.update(Object.changeset(object, %{"stat" => "DOWNLOADED"})) do
        object
      end
    end)
    |> Enum.filter(fn
      %Object{stat: "DOWNLOADED"} -> true
      _ -> false
    end)
  end

end
