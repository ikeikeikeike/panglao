defmodule Panglao.PageController do
  use Panglao.Web, :controller

  alias Panglao.{Object}

  plug :put_layout, "page.html"

  def index(conn, _params) do
    Exq.enqueue Exq, "default", Panglao.Tasks.Remote, []  # gotta remove
    render conn, "index.html"
  end

  def direct(conn, %{"id" => id, "name" => name}) do
    qs =
      from q in Object,
        where: q.id == ^id
           and q.name == ^name,
        limit: 1

    render conn, "direct.html", object: Repo.one!(qs)
  end

  def short(conn,  %{"id" => id, "slug" => slug}) do
    qs =
      from q in Object,
        where: q.id == ^id
           and q.slug == ^slug,
        limit: 1

    render conn, "direct.html", object: Repo.one!(qs)
  end

  def embed(conn, %{"id" => id, "name" => name}) do
    qs =
      from q in Object,
        where: q.id == ^id
           and q.name == ^name,
        limit: 1
    conn
    |> put_resp_header("X-Frame-Options", "ALLOWALL")
    |> render("embed.html", object: Repo.one!(qs))
  end

  def splash(conn, _params) do
    render conn, "splash.html"
  end


end
