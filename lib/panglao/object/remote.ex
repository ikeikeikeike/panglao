defmodule Panglao.Object.Remote do

  alias Panglao.{Repo, Object, Client}

  def upload(%{"remote" => remote} = params) do
    case Repo.get_by(Object, url: remote) do
      nil ->
        upfile params
      object ->
        {:ok, object}
    end
  end
  defp upfile(params) do
    body =
      case Client.Info.get(params["remote"]) do
        {:ok, %HTTPoison.Response{status_code: 200} = r} ->
          r.body
        _ ->
          :error_downloading
      end

    Repo.transaction fn  ->
      with %{}           <- body,
           {:ok, object} <- Repo.insert(Object.remote_changeset(%Object{}, params)),
           {:ok,      _} <- Client.Download.get(object.remote),
           {:ok, object} <- Repo.update(Object.download_changeset(object, %{"remote" => body["outputfile"]})) do

        object
      else
        {:error, %HTTPoison.Error{id: nil, reason: reason}} ->
          Repo.rollback reason

        {:error, %Ecto.Changeset{} = changeset} ->
          Repo.rollback changeset

        msg ->
          Repo.rollback "#{msg}"
      end
    end
  end

end
