defmodule Panglao.Api.V1.RemoteController do
  use Panglao.Web, :controller

  alias Panglao.{Object.Remote, Object.Q, Client.Progress, Hash, Object}

  def upload(conn, %{"url" => url}) do
    user_id  = conn.assigns.current_user.id
    params   = %{"user_id" => user_id, "remote" => url}

    spawn fn -> Remote.upload params end

    json conn, %{message: "ok"}
  end

  def status(conn, %{"url" => url}) do
    user = conn.assigns.current_user
    o = Q.get(%{"user_id" => user.id, "url" => url})

    progress conn, o
  end

  defp progress(conn, o) do
    r = %{
      object_status: o.stat,
      embed: if(o.src, do: page_url(conn, :embed, o, o.src.file_name)),
      short: if(o.src, do: page_url(conn, :short, o, o.slug)),
      direct: if(o.src, do: page_url(conn, :direct, o, o.src.file_name)),
      updated_at: if(o.src, do: o.src.updated_at, else: o.updated_at),
      created_at: o.inserted_at,
      status: nil,
      eta: nil,
      speed: nil,
      percent: nil,
      total_bytes: nil,
    }

    case Progress.get(o.url) do
      {:ok, %{body: b}} ->
        json conn, Map.merge(r, %{
          status: Map.get(b, "status", "finished"),
          eta: Map.get(b, "_eta_str"),
          speed: Map.get(b, "_speed_str"),
          percent: Map.get(b, "_percent_str"),
          total_bytes: Map.get(b, "_total_bytes_estimate_str", Map.get(b, "_total_bytes_str")),
        })
      _ ->
        json conn, r
    end
  end

end
