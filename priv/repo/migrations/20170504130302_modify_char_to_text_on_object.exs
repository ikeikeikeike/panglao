defmodule Panglao.Repo.Migrations.ModifyCharToTextOnObject do
  use Ecto.Migration

  def change do
    alter table(:objects) do
      modify :name, :text
      modify :remote, :text
    end
  end
end
