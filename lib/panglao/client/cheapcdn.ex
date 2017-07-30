defmodule Panglao.Client.Cheapcdn do
  use HTTPoison.Base

  @cdnenv Application.get_env(:panglao, :cheapcdn)

  def process_url(path) do
    Path.join @cdnenv[:endpoint], path
  end

  def process_request_body(body) do
    case body do
      {:form, form} ->
        {:form, transform(form)}
      body ->
        body
    end
  end

  defp transform(payload) do
    for {k, v} <- payload, into: [], do: {:"#{k}", v}
  end

  def process_request_options(options) do
    Keyword.merge options, [recv_timeout: 15_000, timeout: 15_000]
  end

  def process_response_body(body) do
    case Poison.decode body do
      {:ok,    body}        -> body
      {:error, body}        -> body
      {:error, :invalid, 0} -> body
    end
  end

  ### apis

  def gateway(params) do
    opts = [
      hackney: [basic_auth: @cdnenv[:auth]],
      params: Keyword.merge(transform(params), [name: 1]),
    ]
    get @cdnenv[:gateway], [], opts
  end

  def info(key) do
    key = Base.encode64 key
    get Path.join(@cdnenv[:info], key)
  end

  def nodeinfo do
    get @cdnenv[:nodeinfo]
  end

  def abledisk do
    get @cdnenv[:abledisk]
  end

  def progress(key) do
    key = Base.encode64 Path.basename(Path.rootname(key))
    get Path.join(@cdnenv[:progress], key)
  end

  def download(key) do
    key = Base.encode64 key
    get Path.join(@cdnenv[:download], key)
  end

  defdelegate remote_upload(key), to: __MODULE__, as: :download

  def findfile(key) do
    key = Base.encode64 Path.basename(Path.rootname(key))
    get Path.join(@cdnenv[:findfile], key)
  end

  def removefile(key) do
    key = Base.encode64 key
    get Path.join(@cdnenv[:removefile], key)
  end

  def extractors do
    get @cdnenv[:extractors]
  end
  def extractors! do
    case extractors() do
      {:ok, body} ->
        body
      {:error, error} ->
        raise error
    end
  end

end
