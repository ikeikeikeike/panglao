defmodule Panglao.Tasks.Remote do
  import Ecto.Query

  alias Panglao.{Repo, RepoReader, Object, Tasks, ObjectUploader, Client.Cheapcdn}

  require Logger

  def perform do
    queryable =
      from q in Object.with_remote,
        where: q.inserted_at > datetime_add(^Ecto.DateTime.utc, -3, "hour"),
        order_by: fragment("RANDOM()"),
        limit: 100

    Enum.each RepoReader.all(queryable), fn object ->
      with {:ok, %{body: %{"status" => "finished"}}} <- Cheapcdn.progress(object.url, object.remote),
           {:ok, object} <- pending(object) do

        # Convert
        Exq.enqueue Exq, "encoder", Tasks.Encode, [object.id]

        # Make img and remove mp4
        ObjectUploader.local_url {object.src, object}
      else
        # {:ok, %{body: %{}}} ->
          # Repo.update!(Object.changeset(object, %{"stat" => "DOWNLOAD_FAILURE"}))
        msg ->
          Logger.error(inspect msg)
          :try_again
      end
    end
  end

  defp pending(object) do
    params = %{"src" => Path.basename(object.remote)}
    Repo.update Object.object_changeset(object, params)
  end

end
