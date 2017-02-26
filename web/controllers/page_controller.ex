defmodule Panglao.PageController do
  use Panglao.Web, :controller

  plug :put_layout, "page.html"

  def index(conn, _params) do
    render conn, "index.html"
  end
end
