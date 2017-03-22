defmodule Panglao.ObjectUploader do
  use Arc.Definition
  use Arc.Ecto.Definition

  alias Panglao.Hash

  @cdnenv Application.get_env(:panglao, :cheapcdn)
  @versions [:original, :screenshot]
  # @extension_whitelist ~w(.mp4 .flv)
  @acl :public_read


  def transform(:screenshot, _) do
    conv = fn(input, output) ->
      Thumbnex.create_thumbnail input, output, max_width: 700, max_height: 430
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
    Hash.short "#{Path.basename(compatible_name(file), Path.extname(compatible_name(file)))}"
  end

  def storage_dir(_version, {_file, model}) do
    Hash.short model.id
  end

  defp joinpath(version, {file, scope}) do
    dir  = storage_dir version, {file, scope}
    name = filename version, {file, scope}
    ext  =
      case version do
        :original   ->
          Path.extname(compatible_name(file))
        :screenshot ->
          ".jpg"
      end

    Path.join dir, [name, ext]
  end

  def default_url(:original) do
    "https://placehold.it/700x800&txt=SAMPLE IMAGE"
  end

  def develop_url({file, scope}, version \\ :original) do
    Path.join(@cdnenv[:local_host], joinpath(version, {file, scope}))
  end

  def auth_url({file, scope}, version \\ :original) do
    opts   = [hackney: [basic_auth: @cdnenv[:auth]]]
    object = joinpath(version, {file, scope})

    r = HTTPoison.get!("#{@cdnenv[:gateway]}&object=#{object}", [], opts)
    "#{url({file, scope}, version)}&cdnkey=#{r.body}"
  end

  defp compatible_name(file) do
    Map.get file, :file_name, Map.get(file, :filename)
  end

end
