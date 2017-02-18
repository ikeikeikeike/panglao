defmodule Panglao.ObjectUploader do
  use Arc.Definition
  use Arc.Ecto.Definition

  # require Logger

  @versions [
    # :original,
    :screenshot
  ]
  # @extension_whitelist ~w(.mp4 .flv)

  # @acl :public_read
  # def acl(:thumb, _), do: :public_read

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
    [content_type: Plug.MIME.path(file.file_name)] # for "image.png", would produce: "image/png"
  end

  def __storage, do: Arc.Storage.Local
  # def __storage, do: Arc.Storage.S3

  def filename(version, {file, _model}) do
    "#{version}_#{file.file_name}"
  end

  def storage_dir(_version, {_file, model}) do
    "uploads/#{model.id}"
  end

  def default_url(:original) do
    "https://placehold.it/700x800&txt=SAMPLE IMAGE"
  end

  def develop_url({file, scope}, version \\ :original) do
    case __storage() do
      Arc.Storage.Local ->
        Panglao.Endpoint.url <> url({file, scope}, version)
      Arc.Storage.S3 ->
        url({file, scope}, version)
    end
  end

end
