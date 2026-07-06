defmodule ModelCanaan.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string, null: false
      add :slug, :string
      add :description, :string
      # e.g. "admin", "teacher", "parent" — lets you tag a role's category
      add :type, :string
      add :status, :string, default: "active", null: false

      timestamps()
    end

    create unique_index(:roles, [:name])
    create unique_index(:roles, [:slug])
  end
end
