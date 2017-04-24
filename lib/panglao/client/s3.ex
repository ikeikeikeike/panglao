defmodule Panglao.Client.S3 do
  @behaviour ExAws.Request.HttpClient
  @cdnenv Application.get_env(:panglao, :cheapcdn)

  def request(method, url, body, headers, opts) do
    u = URI.parse url

    a = Keyword.merge opts, [hackney: [basic_auth: @cdnenv[:auth], recv_timeout: 1_000_000]]
    h = "#{@cdnenv[:gateway]}&object=#{u.path}"
    b = Poison.decode! HTTPoison.get!(h, [], a).body

    u2 = URI.parse b["host"]
    url =
      %{u | host: u2.host, authority: u2.authority, scheme: u2.scheme}
      |> to_string

    opts = Keyword.merge opts, [hackney: [recv_timeout: 1_000_000]]
    HTTPoison.request method, url, body, headers, opts
  end
end
