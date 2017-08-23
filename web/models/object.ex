defmodule Panglao.Object do
  use Panglao.Web, :model

  alias Panglao.{User, Hash}

  @derive {Poison.Encoder, only: ~w(name slug stat src inserted_at updated_at)a}
  schema "objects" do
    belongs_to :user, User

    field :name, :string
    field :slug, :string

    field :url, :string
    field :remote, :string

    field :stat, :string, default: "NONE"
    field :src, :string

    timestamps()
  end

  @requires ~w()a
  @castable ~w(src name stat slug remote url user_id)a
  @stattypes ~w(
    NONE
    REMOTE DOWNLOAD CRAP WRONG
    PENDING STARTED FAILURE SUCCESS
    REMOVED
  )

  def remote?(struct) do
    struct.stat in ~w(REMOTE DOWNLOAD CRAP WRONG)
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
    |> validate_required(~w(user_id url remote name)a)
    |> put_change(:stat, "REMOTE")
    |> put_change(:slug, Hash.randstring(3))
  end

  def object_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> put_change(:stat, "PENDING")
    |> put_change(:slug, Hash.randstring(3))
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

  def with_wrong(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "WRONG"
  end

  def with_failure(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "FAILURE"
  end

  def with_success(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "SUCCESS"
  end

  def with_crap(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "CRAP"
  end

  def with_download(query \\ __MODULE__) do
    from q in query,
    where: q.stat == "DOWNLOAD"
  end

  def with_remote(query \\ __MODULE__) do
    from q in query,
    where: q.stat in ~w(REMOTE CRAP DOWNLOAD)
  end

  def with_filer(query \\ __MODULE__) do
    from q in query,
    where: not q.stat in ~w(NONE REMOTE CRAP DOWNLOAD)
  end

  @expires Application.get_env(:panglao, :object)[:expires]
  def with_removable(query \\ __MODULE__) do
    expires = -(@expires)
    from q in query,
    where: q.stat != "REMOVED"
       and q.inserted_at < datetime_add(^Ecto.DateTime.utc, ^expires, "hour")
  end
end
