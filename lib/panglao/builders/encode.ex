defmodule Panglao.Builders.Encode do
  import Panglao.Builders.Base
  import Ecto.Query, only: [from: 2]

  alias Panglao.{Repo, Object, ObjectUploader}

  require Logger

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
      Enum.map Repo.all(queryable), fn object ->
        object
        |> Object.encode_changeset(%{"stat" => "STARTED"})
        |> Repo.update

        arc = Arc.File.new ObjectUploader.develop_url({object.src, object})
        ObjectUploader.store({low(arc), object})

        object
        |> Object.encode_changeset(%{"stat" => "SUCCESS"})
        |> Repo.update
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
    args = ["-y", "-i", arc.path, "-vcodec", "libx264", "-crf", "29", out]

    System.cmd "ffmpeg", args, stderr_to_stdout: true
    File.copy out, arc.path
    File.rm out

    %Plug.Upload{
      path: arc.path,
      filename: arc.file_name,
    }
  end

end
