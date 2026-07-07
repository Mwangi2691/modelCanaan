defmodule ModelCanaan.Repo.Migrations.CreateClasses do
  use Ecto.Migration

  def change do
    create table(:classes) do
      add :name, :string, null: false
      add :stream, :string
      add :academic_year, :integer, null: false
      add :status, :string, default: "active", null: false

      timestamps()
    end

    create unique_index(:classes, [:name, :stream, :academic_year])
  end
end
