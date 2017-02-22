defmodule Panglao.Repo.Migrations.CreateObject do
  use Ecto.Migration

  def change do
    create table(:objects) do
      add :src, :text
      add :stat, :string

      timestamps()
    end

  end
end
