defmodule Panglao.Api.ErrorController do
  use Panglao.Web, :controller

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> text("Unauthorized")
  end
end
