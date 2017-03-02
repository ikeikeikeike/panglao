defmodule Panglao.Object.Basic do

  alias Panglao.{Repo, Object}

  def upload(params) do
    Repo.transaction(fn  ->
      with {:ok, object} <- Repo.insert(Object.changeset(%Object{}, params)),
           {:ok, object} <- Repo.update(Object.object_changeset(object, params)) do
        object
      else
        {:error, changeset} -> Repo.rollback changeset
      end
    end)
  end

end
