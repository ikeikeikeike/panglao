defmodule Panglao.Api.V1.ObjectController do
  use Panglao.Web, :controller

  alias Panglao.{ObjectUploader, Object.Q}

  def link(conn, _params) do
    user = conn.assigns.current_user
    json conn, user.id
  end

  def info(conn, _params) do
    user = conn.assigns.current_user
    json conn, user.id
  end

  def rename(conn, _params) do
    user = conn.assigns.current_user
    json conn, user.id
  end

  def upload(conn, _params) do
    user = conn.assigns.current_user
    json conn, user.id
  end

  def splash(conn, %{"id" => _hash} = params) do
    img conn, Q.get!(params)
  end

  def splash(conn, %{"url" => url}) do
    user = conn.assigns.current_user
    img conn, Q.get!(%{"user_id" => user.id, "url" => url})
  end

  defp img(conn, obj) do
    json conn, %{
      src: if(obj.src, do: ObjectUploader.local_url({obj.src, obj})),
      updated: if(obj.src, do: obj.src.updated_at, else: obj.updated_at),
      created: obj.inserted_at,
    }
  end

end
