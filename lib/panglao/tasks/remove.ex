defmodule Panglao.Tasks.Remove do
  # import Panglao.Tasks.Base

  alias Panglao.{Repo, Object, Client.Cheapcdn}

  def perform do
    objects = Repo.all Object.with_removable

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
