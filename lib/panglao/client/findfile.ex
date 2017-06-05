defmodule Panglao.Client.Findfile do
  use HTTPoison.Base

  @endpoint Application.get_env(:panglao, :endpoint)[:findfile]
  @agents Application.get_env(:panglao, :user_agents)
  @options [connect_timeout: 10_000, recv_timeout: 10_000, timeout: 10_000]

  def process_url(url) do
    @endpoint <> Base.encode64(url)
  end

  def process_request_headers(headers) do
    [{"User-Agent", Enum.random(@agents)} | headers]
  end

  def process_request_options(options) do
    Keyword.merge options, @options
  end

  def process_response_body(body) do
    case Poison.decode body do
      {:ok,    body} -> body
      {:error, body} -> body
    end
  end

  def findfile(key) do
    get Path.basename(Path.rootname(key))
  end

end
