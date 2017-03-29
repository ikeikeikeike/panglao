defmodule Panglao.Tasks.Remove do
  import Panglao.Tasks.Base

  alias Panglao.{Repo, Object, ObjectUploader}

  def perform do
    objects = Repo.all Object.with_removable

    Enum.map objects, fn object ->
      with src when not is_nil(src) <- object.src,
           :ok <- ObjectUploader.delete({src.file_name, object}),
           {:ok, object} <- Repo.update(Object.remove_changeset(object)) do
        object
      end
    end
  end
end
