defmodule Panglao.User do
  use Panglao.Web, :model

  schema "users" do
    has_many :authorizations, Panglao.Authorization

    field :email, :string
    field :access_token, :string
    field :access_secret, :string

    timestamps()
  end

  @required ~w(email)a
  @castable ~w(email access_token access_secret)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@required)
    |> validate_format(:email, ~r/@/, message: gettext("Email format is not valid"))
    |> unique_constraint(:email)
  end

  # for user_from_auth.ex
  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
  end

end
