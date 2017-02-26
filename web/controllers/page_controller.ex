defmodule Panglao.PageController do
  use Panglao.Web, :controller

  alias Panglao.{Object}

  plug :put_layout, "page.html"

  def index(conn, _params) do
    render conn, "index.html"
  end

  def direct(conn, _params) do
    object =
      from(q in Object, where: q.id == 10, limit: 1)
      |> Repo.one

    render conn, "direct.html", object: object
  end

  def short(conn, _params) do
    render conn, "short.html"
  end

  def embed(conn, _params) do
    render conn, "embed.html"
  end

  def splash(conn, _params) do
    render conn, "splash.html"
  end


end
