defmodule Panglao.Repo.Migrations.CreateObject do
  use Ecto.Migration

  def change do
    create table(:objects) do
      add :name, :string
      add :slug, :string
      add :stat, :string
      add :src, :text
      add :url, :text
      add :remote, :string

      timestamps()
    end
    create index(:objects, [:name])
    create index(:objects, [:slug])
    create index(:objects, [:stat])
    create index(:objects, [:url])

  end
end
