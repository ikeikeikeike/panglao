defmodule Panglao.Render do
  import Plug.Conn
  import Phoenix.Controller

  alias Panglao.ObjectUploader

  def img(conn, obj) do
    url = ObjectUploader.auth_url {conn, obj.src, obj}, :screenshot
    r   = HTTPoison.get! url

    conn
    |> put_resp_header("Content-Length", hhd(r.headers, "Content-Length"))
    |> put_resp_header("Accept-Ranges", hhd(r.headers, "Accept-Ranges"))
    |> put_resp_content_type(hhd(r.headers, "Content-Type"))
    |> text(r.body)
  end

  defp hhd(headers, key) do
    for({k, v} <- headers, k == key, do: v) |> List.last
  end

end
