defmodule Panglao.Tasks.Remove do
  import Panglao.Tasks.Base

  alias Panglao.{Repo, Object, Client.Removefile}

  def perform do
    objects = Repo.all Object.with_removable

    Enum.map objects, fn object ->
      with src when not is_nil(src) <- object.src,
          {:ok, _} <- Removefile.removefile(src) do
        nil
      end

      Repo.update(Object.remove_changeset(object))
    end
  end
end
