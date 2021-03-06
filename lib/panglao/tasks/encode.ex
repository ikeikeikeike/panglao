defmodule Panglao.Tasks.Encode do
  import Panglao.Tasks.Base
  import Ecto.Query, only: [from: 2]

  alias Panglao.{Repo, RepoReader, Object, ObjectUploader}

  require Logger

  @config Application.get_env(:panglao, :convert)

  def perform(id) do
    queryable =
      from q in Object.with_base,
        where: q.id == ^id

    encode queryable
  end

  def perform do
    queryable =
      from q in Object.with_pending,
        order_by: q.updated_at,
        limit: 2

    encode queryable
  end

  defp encode(queryable) do
    result =
      Enum.map RepoReader.all(queryable), fn object ->
        started object

        try do
          if @config[:encode] do
            url = ObjectUploader.auth_url({object.src, object})
            ObjectUploader.store({low(Arc.File.new(url)), object})
          end

          success object
        rescue
          _ -> failure object
        catch
          _ -> failure object
        end
      end

    Enum.map(result, fn
      {:error, object} ->
        skip object, "final"
      _ ->
        nil
    end)
    |> Enum.filter(&is_nil/1)
    |> length
  end

  defp low(arc) do
    out  = "#{arc.path}.encode.mp4"
    args = ["-y", "-i", arc.path, "-vcodec", "libx264", "-crf", "28", out]

    System.cmd "ffmpeg", args, stderr_to_stdout: true
    File.copy out, arc.path
    File.rm out

    %Plug.Upload{
      path: arc.path,
      filename: arc.file_name,
    }
  end

  defp started(object) do
    object
    |> Object.encode_changeset(%{"stat" => "STARTED"})
    |> Repo.update
  end

  defp success(object) do
    object
    |> Object.encode_changeset(%{"stat" => "SUCCESS"})
    |> Repo.update
  end

  defp failure(object) do
    object
    |> Object.encode_changeset(%{"stat" => "FAILURE"})
    |> Repo.update
  end

end
