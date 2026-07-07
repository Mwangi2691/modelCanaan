defmodule ModelCanaan.Repo.Migrations.CreateTeacherClassAssignments do
  use Ecto.Migration

  def change do
    create table(:teacher_class_assignments) do
      add :teacher_id, references(:users, on_delete: :delete_all), null: false
      add :class_id, references(:classes, on_delete: :delete_all), null: false
      add :assigned_by_id, references(:users, on_delete: :nilify_all)
      add :status, :string, default: "active", null: false

      timestamps()
    end

    create unique_index(:teacher_class_assignments, [:teacher_id, :class_id])
    create index(:teacher_class_assignments, [:class_id])
  end
end
