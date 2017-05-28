defmodule Panglao.Client.Removefile do
  use HTTPoison.Base

  @endpoint Application.get_env(:panglao, :endpoint)[:removefile]
  @agents Application.get_env(:panglao, :user_agents)
  @options [connect_timeout: 60_000, recv_timeout: 60_000, timeout: 60_000]

  def process_url(key) do
    @endpoint <> Base.encode64(key)
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

  def removefile(key) do
    get key
  end

end
