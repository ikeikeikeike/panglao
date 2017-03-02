defmodule Panglao.Object.Remote do

  alias Panglao.{Repo, Object, Client}

  def upload(params) do
    Repo.transaction fn  ->
      with {:ok, object} <- Repo.insert(Object.remote_changeset(%Object{}, params)),
           {:ok, %HTTPoison.Response{status_code: 200} = r} <- Client.Info.get(object.remote),
           {:ok,      _} <- Client.Download.get(object.remote),
           {:ok, object} <- Repo.update(Object.download_changeset(object, %{"remote" => r.body[:outputfile]})) do

        object
      else
        {:error, %HTTPoison.Error{id: nil, reason: reason}} ->
          Repo.rollback reason

        {:error, %Ecto.Changeset{} = changeset} ->
          Repo.rollback changeset

        _ ->
          Repo.rollback :unknown
      end
    end
  end

end
