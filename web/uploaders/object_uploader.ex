defmodule Panglao.ObjectUploader do
  use Arc.Definition
  use Arc.Ecto.Definition
  # require Logger

  @cdnenv Application.get_env(:panglao, :cheapcdn)
  @versions [:original] # :screenshot
  # @extension_whitelist ~w(.mp4 .flv)
  @acl :public_read

  def validate({_file, _}) do
    # file_extension = file.file_name |> Path.extname |> String.downcase
    # Enum.member?(@extension_whitelist, file_extension)
    true
  end

  # def transform(:screenshot, _) do
  #   conv = fn(input, output) ->
  #     src =
  #       if Path.extname(input) in @extension_whitelist do
  #         input
  #       else
  #         dst = Path.join(System.tmp_dir, "#{Mail.Hash.randstring(10)}.html")
  #         File.copy input, dst
  #         dst
  #       end

  #     cmdopt = "--format jpg #{src} #{output}"
  #     Logger.debug "Run cmd in #{inspect __MODULE__}: wkhtmltoimage #{cmdopt}"
  #     cmdopt
  #   end

  #   {:wkhtmltoimage, conv, :jpg}
  # end

  # https://github.com/stavro/arc#s3-object-headers
  def s3_object_headers(_version, {file, _scope}) do
    [content_type: Plug.MIME.path(file.file_name)]
  end

  # def __storage, do: Arc.Storage.Local
  # def __storage, do: Arc.Storage.S3

  def filename(_version, {file, model}) do
    "#{Path.basename(file.file_name, Path.extname(file.file_name))}#{model.id}"
  end

  def storage_dir(_version, {_file, _model}) do
    ""
  end

  def default_url(:original) do
    "https://placehold.it/700x800&txt=SAMPLE IMAGE"
  end

  def auth_url({file, scope}, version \\ :original) do
    opts   = [hackney: [basic_auth: @cdnenv[:auth]]]
    object = filename(version, {file, scope})

    r = HTTPoison.get!("#{@cdnenv[:gateway]}&object=#{object}", [], opts)
    "#{url({file, scope}, version)}&cdnkey=#{r.body}"
  end
end
