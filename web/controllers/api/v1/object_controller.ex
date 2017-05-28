defmodule Panglao.Api.V1.ObjectController do
  use Panglao.Web, :controller

  alias Panglao.{ObjectUploader, Object.Q, Client}

  def link(conn, _params) do
    user = conn.assigns.current_user
    json conn, user.id
  end

  def info(conn, %{"id" => _hash} = params) do
    obj = Q.get!(params)

    case Client.Info.get(obj.url) do
      {:ok, %{body: body}} ->
        json conn, body
      _ ->
        json conn, %{}
    end
  end
  # No need auth
  def info(conn, %{"url" => url}) do
    case Client.Info.get(url) do
      {:ok, %{body: body}} ->
        json conn, body
      _ ->
        json conn, %{}
    end
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
      src: ObjectUploader.local_url(if obj.src, do: {obj.src, obj}, else: obj),
      updated_at: if(obj.src, do: obj.src.updated_at, else: obj.updated_at),
      created_at: obj.inserted_at,
    }
  end

end
