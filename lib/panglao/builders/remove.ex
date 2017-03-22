defmodule Panglao.Builders.Remove do
  import Panglao.Builders.Base

  alias Panglao.{Repo, Object}

  def perform do
    objects = Repo.all Object.with_removable

    Enum.map objects, fn object ->
      with :ok, ObjectUploader.delete({object.src.file_name, object}),
           {:ok, object} <- Repo.update(Object.remove_changeset(object)) do
        object
      end
    end
  end
end
