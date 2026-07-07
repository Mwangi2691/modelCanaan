defmodule ModelCanaan.Repo.Migrations.CreateStudentRecordAccess do
  use Ecto.Migration

  def change do
    create table(:student_record_access) do
      add :teacher_id, references(:users, on_delete: :delete_all), null: false
      add :student_id, references(:students, on_delete: :delete_all), null: false
      add :granted_by_id, references(:users, on_delete: :nilify_all)
      add :status, :string, default: "active", null: false

      timestamps()
    end

    create unique_index(:student_record_access, [:teacher_id, :student_id])
    create index(:student_record_access, [:student_id])
  end
end
