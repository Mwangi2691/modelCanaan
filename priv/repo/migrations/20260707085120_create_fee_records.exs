defmodule ModelCanaan.Repo.Migrations.CreateFeeRecords do
  use Ecto.Migration

  def change do
    create table(:fee_records) do
      add :student_id, references(:students, on_delete: :delete_all), null: false
      add :academic_year, :integer, null: false
      add :term, :string, null: false
      add :amount_due, :decimal, null: false
      add :amount_paid, :decimal, default: 0.0, null: false
      # "unpaid", "partial", "paid"
      add :status, :string, default: "unpaid", null: false

      timestamps()
    end

    create unique_index(:fee_records, [:student_id, :academic_year, :term])
  end
end
