defmodule Panglao.ObjectUploader do
  use Arc.Definition
  use Arc.Ecto.Definition

  alias Panglao.Hash

  @cdnenv Application.get_env(:panglao, :cheapcdn)
  @versions [:original] # :screenshot
  # @extension_whitelist ~w(.mp4 .flv)
  @acl :public_read

  def validate({_file, _}) do
    # file_extension = file.file_name |> Path.extname |> String.downcase
    # Enum.member?(@extension_whitelist, file_extension)
    true
  end

  # https://github.com/stavro/arc#s3-object-headers
  def s3_object_headers(_version, {file, _scope}) do
    [content_type: Plug.MIME.path(file.file_name)]
  end

  # def __storage, do: Arc.Storage.Local
  # def __storage, do: Arc.Storage.S3

  def filename(_version, {file, _model}) do
    "#{Path.basename(file.file_name, Path.extname(file.file_name))}"
  end

  def storage_dir(_version, {_file, model}) do
    Hash.short model.id
  end

  defp joinpath(version, {file, scope}) do
    Path.join storage_dir(version, {file, scope}), file.file_name
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

end
