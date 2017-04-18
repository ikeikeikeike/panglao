defmodule Panglao.Mapper.Object do
  import Panglao.Router.Helpers

  def link(conn, %{object: o}) do
    %{
      object_status: o.stat,
      embed: if(o.src, do: page_url(conn, :embed, o, o.src.file_name), else: error_url(conn, :unavailable)),
      short: if(o.src, do: page_url(conn, :short, o, o.slug), else: error_url(conn, :unavailable)),
      direct: if(o.src, do: page_url(conn, :direct, o, o.src.file_name), else: error_url(conn, :unavailable)),
      updated_at: if(o.src, do: o.src.updated_at, else: o.updated_at),
      created_at: o.inserted_at,
    }
  end

end
