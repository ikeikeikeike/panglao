defmodule Panglao.Api.V1.RemoteController do
  use Panglao.Web, :controller

  alias Panglao.{Object, Object.Remote, Client.Progress, Hash}

  def upload(conn, %{"url" => url}) do
    user_id  = conn.assigns.current_user.id
    params   = %{"user_id" => user_id, "remote" => String.trim(url)}

    case Remote.upload(params) do
      {:error, %Ecto.Changeset{} = c} ->
        errors = Enum.map c.errors, fn {field, msg} ->
          "#{translate_default field} #{translate_error msg}"
        end
        json conn, Enum.join(errors, "\n")

      {:error, message} ->
        json conn, "#{message}"

      {:ok, object} ->
        json conn, %{
          status_id: Hash.encrypt(object.id),
          name: object.name,
          created: object.inserted_at,
        }
    end
  end

  def status(conn, %{"id" => hash}) do
    o =
      with id when not is_nil(id) <- Hash.decrypt(hash),
           o <- Repo.get!(Object, id) do
        o
      else _ ->
        raise Ecto.NoResultsError
      end

    case Progress.get(o.remote) do
      {:ok, %{body: b}} ->
        json conn, %{
          short: if(o.src, do: page_url(conn, :short, o, o.slug)),
          direct: if(o.src, do: page_url(conn, :direct, o, o.src.file_name)),
          embed: if(o.src, do: page_url(conn, :embed, o, o.src.file_name)),
          status: Map.get(b, "status", "finished"),
          eta: Map.get(b, "_eta_str"),
          speed: Map.get(b, "_speed_str"),
          percent: Map.get(b, "_percent_str"),
          total_bytes: Map.get(b, "_total_bytes_estimate_str", Map.get(b, "_total_bytes_str")),
        }
      _ ->
        json conn, %{}
    end

  end

end
