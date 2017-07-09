defmodule Panglao.Mapper.Object do
  import Panglao.Router.Helpers

  alias Panglao.{Render}

  def link(conn, %{object: o}) do
    %{
      object_status: o.stat,
      embed:  _u(if(o.src, do: page_url(conn, :embed, o, URI.encode(o.src)), else: error_url(conn, :unavailable))),
      short:  _u(if(o.src, do: page_url(conn, :short, o, o.slug), else: error_url(conn, :unavailable))),
      direct: _u(if(o.src, do: page_url(conn, :direct, o, URI.encode(o.src)), else: error_url(conn, :unavailable))),
      updated_at: o.updated_at,
      created_at: o.inserted_at,
    }
  end

  defp _u(url) do
    Render.elastic_secure_url url
  end

end
