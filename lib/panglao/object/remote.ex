defmodule Panglao.Object.Remote do

  alias Panglao.{Repo, RepoReader, Object, Tasks, Client.Cheapcdn}

  def upload(%{"user_id" => user_id, "remote" => remote} = params) do
    case RepoReader.gets_by(Object, user_id: user_id, url: remote) do
      nil ->
        upfile params
      %{stat: "REMOVED"} = object ->
        upfile params, object
      %{stat: "CRAP"} = object ->
        upfile params, object
      %{stat: "REMOTE"} = object ->
        Exq.enqueue Exq, "default", Tasks.Remote2, [object.id]
      object ->
        {:ok, object}
    end
  end
  defp upfile(params, object \\ %Object{}) do
    url = params["remote"]
    precheck =
      case Cheapcdn.info(url, url) do
        {:ok, %HTTPoison.Response{status_code: 200} = r} ->
          r.body
        _ ->
          :error_downloading
      end

    Repo.transaction fn  ->
      with %{"root" => _} <- precheck,
           {:ok, %{body: %{"root" => body}}} <- Cheapcdn.remote_upload(url, url),
           {:ok, object} <- upsert_object(object, params, body) do

        Exq.enqueue Exq, "default", Tasks.Remote2, [object.id]

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

  defp upsert_object(object, params, body) do
    merged = %{
      "user_id" => params["user_id"],
      "url" => params["remote"] || body["webpage_url"],
      "name" => body["title"],
      "remote" => body["outfile"],
    }

    Repo.insert_or_update Object.remote_changeset(object, merged)
  end
end
