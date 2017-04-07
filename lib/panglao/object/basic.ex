defmodule Panglao.Object.Basic do
  alias Panglao.{Repo, Object}

  require Logger

  def upload(params) do
    Repo.transaction fn  ->
      with {:ok, object} <- Repo.insert(Object.changeset(%Object{}, params)),
           {:ok, object} <- Repo.update(Object.object_changeset(object, params)) do
        object
      else
        {:error, changeset} -> Repo.rollback changeset
      end
    end
  rescue
    err ->
      Logger.warn "#{inspect(err)}"
      err
  catch
    err ->
      Logger.warn "#{inspect(err)}"
      err
  end

  def upload(%Object{} = object, params) do
    Repo.transaction fn  ->
      with {:ok, object} <- Repo.update(Object.object_changeset(object, params)) do
        object
      else
        {:error, changeset} -> Repo.rollback changeset
      end
    end
  rescue
    err ->
      Logger.warn "#{inspect(err)}"
      err
  catch
    err ->
      Logger.warn "#{inspect(err)}"
      err
  end

end
