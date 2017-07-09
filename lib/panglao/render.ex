defmodule Panglao.Render do
  import Plug.Conn
  import Phoenix.Controller

  alias Panglao.ObjectUploader

  @env Application.get_env(:panglao, :env)

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

  def secure_url(url) do
    (%URI{URI.parse(url) | scheme: "https", port: 443}) |> to_string
  end

  def elastic_secure_url(url) do
    case @env do
      :prod ->
        secure_url url
      _     ->
        url
    end
  end

end
