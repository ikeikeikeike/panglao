defmodule Panglao.Api.V1.ObjectController do
  use Panglao.Web, :controller

  alias Panglao.{ObjectUploader, Object.Q, Client.Cheapcdn}

  def link(conn, _params) do
    user = conn.assigns.current_user
    json conn, user.id
  end

  def alive(conn, %{"url" => url}) do
    user = conn.assigns.current_user
    json conn, Q.get!(%{"user_id" => user.id, "url" => url})
  end

  def info(conn, %{"id" => _hash} = params) do
    obj = Q.get!(params)

    case Cheapcdn.info(obj.url) do
      {:ok, %{body: %{"root" => _} = body}} ->
        json conn, body
      {:ok, %{body: %{"errno" => _} = body}} ->
        json conn, body
      _ ->
        json conn, %{}
    end
  end
  # No need auth
  def info(conn, %{"url" => url}) do
    case Cheapcdn.info(url) do
      {:ok, %{body: %{"root" => _} = body}} ->
        json conn, body
      {:ok, %{body: %{"errno" => _} = body}} ->
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

  def audio(conn, %{"id" => _hash} = params) do
    mp3 conn, Q.get!(params)
  end

  def audio(conn, %{"url" => url}) do
    user = conn.assigns.current_user
    mp3 conn, Q.get!(%{"user_id" => user.id, "url" => url})
  end

  defp mp3(conn, obj) do
    arg = {conn, obj.src, obj}
    json conn, %{src: ObjectUploader.auth_url(arg, :audio)}
  end

  def preview(conn, %{"id" => _hash} = params) do
    mp4 conn, Q.get!(params)
  end

  def preview(conn, %{"url" => url}) do
    user = conn.assigns.current_user
    mp4 conn, Q.get!(%{"user_id" => user.id, "url" => url})
  end

  defp mp4(conn, obj) do
    arg = {conn, obj.src, obj}
    json conn, %{src: ObjectUploader.auth_url(arg, :preview)}
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
      updated_at: obj.updated_at,
      created_at: obj.inserted_at,
    }
  end

end
