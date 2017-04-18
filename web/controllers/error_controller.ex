defmodule Panglao.ErrorController do
  use Panglao.Web, :controller

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, gettext("You must be logged in to access that page"))
    |> redirect(to: auth_path(conn, :login, "identity"))
  end

  def unavailable(conn, _params) do
    conn
    |> put_layout("page.html")
    |> render("unavailable.html")
  end

end
