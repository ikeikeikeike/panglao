defmodule Panglao.MultipleController do
  use Panglao.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
