defmodule ModelCanaan.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :middle_name, :string
      add :last_name, :string
      add :email, :string
      add :phone_number, :string
      add :gender, :string
      add :password_hash, :string
      add :status, :string
      add :last_login_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create index(:users, [:status])
  end
end
