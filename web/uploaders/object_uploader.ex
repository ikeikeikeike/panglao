defmodule Panglao.ObjectUploader do
  use Arc.Definition

  alias Panglao.{Router, Endpoint, Render}

  @env Application.get_env(:panglao, :env)
  @cdnenv Application.get_env(:panglao, :cheapcdn)

  @versions [:original]
  # @extension_whitelist ~w(.mp4 .flv)
  # @acl :public_read

  def validate({_file, _}) do
    # file_extension = file.file_name |> Path.extname |> String.downcase
    # Enum.member?(@extension_whitelist, file_extension)
    true
  end

  # https://github.com/stavro/arc#s3-object-headers
  def s3_object_headers(_version, {file, _scope}) do
    [content_type: Plug.MIME.path(compatible_name(file)), timeout: 1_000_000]
  end

  # def __storage, do: Arc.Storage.Local
  # def __storage, do: Arc.Storage.S3

  def filename(_version, {file, _model}) do
    Path.basename compatible_name(file), Path.extname(compatible_name(file))
  end

  def storage_dir(_version, {_file, _model}) do
    ""
  end

  def transform(:screenshot, _) do
    {nil, nil, :jpg}
  end

  def local_url(name, version \\ :screenshot)

  def local_url({file, scope}, version) do
    file  = file || %Arc.File{file_name: scope.name}
    fdir  = Path.join splash_dir(), "priv/static/splash"
    fname = Path.basename url({file, scope}, version)
    fpath = Path.join fdir, fname

    unless File.exists?(fpath) do
      fimg = auth_url {file, scope}, version
      File.mkdir_p fdir
      File.write fpath, HTTPoison.get!(fimg).body
    end

    src = Router.Helpers.static_url Endpoint, "/splash/#{fname}"
    case @env do
      :prod ->
        Render.secure_url src
      _     ->
        src
    end
  end
  def local_url(scope, _version) do
    local_url {nil, scope}
  end

  def default_url(:original) do
    "https://placehold.it/700x800&txt=SAMPLE IMAGE"
  end

  def auth_url(tuple, version \\ :original)

  def auth_url({file, scope}, version) do
    fetch_auth_url {"", file, scope}, version
  end

  def auth_url({conn, file, scope}, version) do
    ip = Tuple.to_list(conn.remote_ip) |> Enum.join(".")

    fetch_auth_url {"&ipaddr=#{ip}", file, scope}, version
  end

  defp fetch_auth_url({path, file, scope}, version) do
    opt = [hackney: [basic_auth: @cdnenv[:auth]]]
    o   = Path.basename url({file, scope}, version)

    h   = "#{@cdnenv[:gateway]}&object=#{o}" <> path
    key = Poison.decode! HTTPoison.get!(h, [], opt).body

    "#{url({file, scope}, version)}?cdnkey=#{key}"
  end

  defp compatible_name(file)
    when is_binary(file) or is_atom(file) do
    file
  end
  defp compatible_name(file) do
    Map.get file, :file_name, Map.get(file, :filename)
  end

  defp splash_dir do
    case @env do
      :prod ->
        System.user_home
      _    ->
        File.cwd!
    end
  end

end
