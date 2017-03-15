defmodule Panglao.Repo.Migrations.CreateAuthorizations do
  use Ecto.Migration

  def change do
  	create table(:authorizations) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :provider, :string
      add :uid, :string
      add :token, :text
      add :refresh_token, :text
      add :expires_at, :bigint

      timestamps()
    end

    create index(:authorizations, [:user_id])
    create index(:authorizations, [:provider, :uid], unique: true)
    create index(:authorizations, [:expires_at])

  end
end
