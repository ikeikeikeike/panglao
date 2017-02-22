defmodule Panglao.Object do
  use Panglao.Web, :model
  use Arc.Ecto.Schema

  alias Panglao.{ObjectUploader}

  @derive {Poison.Encoder, only: ~w(src stat inserted_at updated_at)a}
  schema "objects" do
    field :src, ObjectUploader.Type
    field :stat, :string

    timestamps()
  end

  @castable ~w()a
  @requires ~w()a
  @attaches ~w(src)a
  @stattypes ~w(PENDING STARTED FAILURE SUCCESS)

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

end
