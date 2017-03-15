defmodule Panglao.MultipleController do
  use Panglao.Web, :controller

  plug Panglao.Plug.CurrentUser

  def index(conn, _params) do
    render conn, "index.html"
  end
end
