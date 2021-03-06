defmodule Panglao.Api.V1.RemoteController do
  use Panglao.Web, :controller

  alias Panglao.{Object.Remote, Object.Q, Object.Progress, Mapper, Client.Cheapcdn}

  def support(conn, _params) do
    json conn, Cheapcdn.extractors!.body["root"]
  end

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
    r = Mapper.Object.link conn, %{object: o}
    b = Progress.get(o)

    json conn, Map.merge(r, b)
  end
end
