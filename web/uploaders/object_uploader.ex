defmodule Panglao.ObjectUploader do
  use Arc.Definition
  use Arc.Ecto.Definition

  alias Panglao.{Hash, Helpers, Router, Endpoint}

  @cdnenv Application.get_env(:panglao, :cheapcdn)
  @versions [:original, :screenshot]
  # @extension_whitelist ~w(.mp4 .flv)
  @acl :public_read


  def transform(:screenshot, _) do
    conv = fn(input, output) ->
      try do
        Thumbnex.create_thumbnail input, output, max_width: 700, max_height: 430
      rescue _ ->
        File.write output, Panglao.File.decode_datauri(Helpers.fallback)
      end

      output
    end

    {:file, conv, :jpg}
  end

  def validate({_file, _}) do
    # file_extension = file.file_name |> Path.extname |> String.downcase
    # Enum.member?(@extension_whitelist, file_extension)
    true
  end

  # https://github.com/stavro/arc#s3-object-headers
  def s3_object_headers(_version, {file, _scope}) do
    [content_type: Plug.MIME.path(compatible_name(file))]
  end

  # def __storage, do: Arc.Storage.Local
  # def __storage, do: Arc.Storage.S3

  def filename(_version, {file, _model}) do
    Path.basename(compatible_name(file), Path.extname(compatible_name(file)))
    |> Hash.short
  end

  def storage_dir(_version, {_file, model}) do
    Hash.short model.id
  end

  defp file_ext(version, {file, _model}) do
    case version do
      :original   ->
        Path.extname(compatible_name(file))
      :screenshot ->
        ".jpg"
    end
  end

  defp joinpath(version, {file, scope}) do
    dir  = storage_dir version, {file, scope}
    name = filename version, {file, scope}
    ext  = file_ext version, {file, scope}

    Path.join dir, [name, ext]
  end

  def local_url(name, version \\ :screenshot)

  def local_url({file, scope}, version) do
    file  = file || %Arc.File{file_name: scope.name}

    fext  = file_ext(version, {file, scope})
    fname = "#{Hash.short(scope.id)}#{fext}"
    fdir  = Path.join System.user_home, "priv/static/splash"
    fpath = Path.join fdir, fname

    if Mix.env == :dev do
      develop_url {file, scope}, version
    else
      unless File.exists?(fpath) do
        fimg = develop_url {file, scope}, version
        File.mkdir_p fdir
        File.write fpath, HTTPoison.get!(fimg).body
      end

      Router.Helpers.static_url(Endpoint, "/splash/#{fname}")
      |> Render.secure_url
    end
  end
  def local_url(scope, version) do
    local_url {nil, scope}
  end

  def default_url(:original) do
    "https://placehold.it/700x800&txt=SAMPLE IMAGE"
  end

  def develop_url({file, scope}, version \\ :original) do
    Path.join(Enum.random(@cdnenv[:objects]), joinpath(version, {file, scope}))
  end

  def auth_url(tuple, version \\ :original)

  def auth_url({file, scope}, version) do
    fetch_auth_url {"", file, scope}, version
  end

  def auth_url({conn, file, scope}, version) do
    ip  = Tuple.to_list(conn.remote_ip) |> Enum.join(".")
    fetch_auth_url {"&ipaddr=#{ip}", file, scope}, version
  end

  defp fetch_auth_url({path, file, scope}, version) do
    opt = [hackney: [basic_auth: @cdnenv[:auth]]]
    o   = joinpath(version, {file, scope})

    url = "#{@cdnenv[:gateway]}&object=#{o}" <> path
    r   = HTTPoison.get! url, [], opt

    "#{url({file, scope}, version)}&cdnkey=#{r.body}"
  end

  defp compatible_name(file) do
    Map.get file, :file_name, Map.get(file, :filename)
  end
end
