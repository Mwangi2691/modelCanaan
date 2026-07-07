defmodule ModelCanaan.Repo.Migrations.CreateStudents do
  use Ecto.Migration

  def change do
    create table(:students) do
      add :first_name, :string, null: false
      add :middle_name, :string
      add :last_name, :string, null: false
      add :admission_number, :string, null: false
      add :gender, :string
      add :date_of_birth, :date
      add :class_id, references(:classes, on_delete: :nilify_all)
      add :parent_id, references(:users, on_delete: :nilify_all)
      add :status, :string, default: "active", null: false

      timestamps()
    end

    create unique_index(:students, [:admission_number])
    create index(:students, [:class_id])
    create index(:students, [:parent_id])
  end
end
