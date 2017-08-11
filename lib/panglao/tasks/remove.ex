defmodule Panglao.Tasks.Remove do
  # import Panglao.Tasks.Base

  import Ecto.Query
  alias Panglao.{Repo, Object, Client.Cheapcdn}

  def perform do
    Object.with_removable
    |> Repo.all
    |> remove()
  end

  def perform(:disksize) do
    Enum.each Cheapcdn.abledisk, fn {client, resp} ->
      with %{body: %{"root" => false}} <- resp do
        from(q in Object, where: q.stat != "REMOVED", order_by: :id, limit: 200)
        |> Repo.all
        |> Enum.filter(&Cheapcdn.exists?(client, &1.url))
        |> remove()
      end
    end
  end

  defp remove(objects) do
    Enum.each objects, fn object ->
      with src when is_binary(src)
                and byte_size(src) > 0 <- object.src,
          {:ok, _} <- Cheapcdn.removefile(object.url, src) do
        nil
      end

      Repo.update(Object.remove_changeset(object))
    end
  end
end
