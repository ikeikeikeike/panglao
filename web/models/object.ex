defmodule Panglao.Object do
  use Panglao.Web, :model
  use Arc.Ecto.Schema

  alias Panglao.{ObjectUploader}

  @derive {Poison.Encoder, only: ~w(src inserted_at updated_at)a}
  schema "objects" do
    field :src, ObjectUploader.Type

    timestamps()
  end

  @castable ~w()a
  @requires ~w()a
  @attaches ~w(src)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
  end

  def tpl_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> cast_attachments(params, @attaches)
  end

end
