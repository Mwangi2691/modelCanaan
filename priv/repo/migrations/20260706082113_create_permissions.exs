defmodule ModelCanaan.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :name, :string, null: false
      add :slug, :string
      # e.g. "read", "write", "manage"
      add :action, :string, null: false
      # e.g. "students", "grades", "fees", "reports"
      add :resource, :string, null: false
      add :status, :string, default: "active", null: false

      timestamps()
    end

    create unique_index(:permissions, [:name, :action, :resource],
             name: :permissions_name_action_resource_index
           )
    create unique_index(:permissions, [:slug])
  end
end
