defmodule Panglao.Repo.Migrations.CreateObject do
  use Ecto.Migration

  def change do
    create table(:objects) do
      add :src, :string

      timestamps()
    end

  end
end
