defmodule Panglao.Api.V1.ObjectController do
  use Panglao.Web, :controller

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

  def splash(conn, _params) do
    user = conn.assigns.current_user
    json conn, user.id
  end

end
