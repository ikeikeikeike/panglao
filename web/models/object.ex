defmodule Panglao.Object do
  use Panglao.Web, :model
  use Arc.Ecto.Schema

  alias Panglao.{ObjectUploader}

  @derive {Poison.Encoder, only: ~w(src stat inserted_at updated_at)a}
  schema "objects" do
    field :name, :string
    field :stat, :string, default: "NONE"
    field :src, ObjectUploader.Type

    timestamps()
  end

  @requires ~w(name)a
  @castable ~w(name stat)a
  @attaches ~w(src)a
  @stattypes ~w(NONE PENDING STARTED FAILURE SUCCESS)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
  end

  def object_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> cast_attachments(params, @attaches)
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

end
