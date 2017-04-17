defmodule Panglao.Object do
  use Panglao.Web, :model
  use Arc.Ecto.Schema

  alias Panglao.{User, ObjectUploader, Hash}

  @derive {Poison.Encoder, only: ~w(name slug stat src inserted_at updated_at)a}
  schema "objects" do
    belongs_to :user, User

    field :name, :string
    field :slug, :string

    field :url, :string
    field :remote, :string

    field :stat, :string, default: "NONE"
    field :src, ObjectUploader.Type

    timestamps()
  end

  @requires ~w()a
  @castable ~w(name stat slug remote url user_id)a
  @attaches ~w(src)a
  @stattypes ~w(
    NONE
    REMOTE DOWNLOAD DOWNLOAD_FAILURE DOWNLOADED
    PENDING STARTED FAILURE SUCCESS
    REMOVED
  )

  def remote?(struct) do
    struct.stat in ~w(REMOTE DOWNLOAD DOWNLOAD_FAILURE DOWNLOADED)
  end

  def object?(struct) do
    struct.stat in ~w(PENDING STARTED FAILURE SUCCESS)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
  end

  def remote_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> validate_required(~w(remote)a)
    |> put_change(:stat, "REMOTE")
    |> put_change(:url, params["remote"])
    |> put_change(:slug, Hash.randstring(3))
  end

  def download_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> validate_required(~w(remote)a)
    |> put_change(:name, Path.basename params["remote"])
    |> put_change(:stat, "DOWNLOAD")
  end

  def object_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> put_change(:stat, "PENDING")
    |> put_change(:slug, Hash.randstring(3))
    |> cast_attachments(params, @attaches)
  end

  def remove_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> put_change(:stat, "REMOVED")
    |> put_change(:src, nil)
  end

  def encode_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> validate_inclusion(:stat, @stattypes)
  end

  def with_base(query \\ __MODULE__) do
    query
  end

  def with_none(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "NONE"
  end

  def with_pending(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "PENDING"
  end

  def with_started(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "STARTED"
  end

  def with_failure(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "FAILURE"
  end

  def with_success(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "SUCCESS"
  end

  def with_download(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "DOWNLOAD"
  end

  def with_download_failure(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "DOWNLOAD_FAILURE"
  end

  def with_downloaded(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "DOWNLOADED"
  end

  def with_remote(query \\ __MODULE__) do
    from q in query,
    where: q.stat in ~w(REMOTE DOWNLOAD)
  end

  def with_filer(query \\ __MODULE__) do
    from q in query,
    where: not q.stat in ~w(NONE REMOTE DOWNLOAD DOWNLOADED)
  end

  @expires Application.get_env(:panglao, :object)[:expires]
  def with_removable(query \\ __MODULE__) do
    expires = -(@expires)
    from q in query,
    where: q.stat != "REMOVED"
       and q.inserted_at < datetime_add(^Ecto.DateTime.utc, ^expires, "hour")
  end
end
