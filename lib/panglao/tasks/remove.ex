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
    with {:ok, %{"root" => false}} <- Cheapcdn.abledisk do
      from(q in Object, where: q.stat != "REMOVED", order_by: :id, limit: 20)
      |> Repo.all
      |> remove()
    end
  end

  defp remove(objects) do
    Enum.map objects, fn object ->
      with src when is_binary(src)
                and byte_size(src) > 0 <- object.src,
          {:ok, _} <- Cheapcdn.removefile(src) do
        nil
      end

      Repo.update(Object.remove_changeset(object))
    end
  end
end
