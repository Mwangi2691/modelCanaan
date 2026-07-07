defmodule ModelCanaan.Repo.Migrations.CreateTeacherReports do
  use Ecto.Migration

  def change do
    create table(:teacher_reports) do
      add :teacher_id, references(:users, on_delete: :delete_all), null: false
      add :class_id, references(:classes, on_delete: :delete_all), null: false
      add :title, :string, null: false
      add :content, :text, null: false
      # "submitted", "reviewed"
      add :status, :string, default: "submitted", null: false
      add :reviewed_by_id, references(:users, on_delete: :nilify_all)
      add :reviewed_at, :utc_datetime

      timestamps()
    end

    create index(:teacher_reports, [:class_id])
    create index(:teacher_reports, [:teacher_id])
  end
end
