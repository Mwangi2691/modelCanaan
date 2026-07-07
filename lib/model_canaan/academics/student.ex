defmodule ModelCanaan.Academics.Student do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModelCanaan.Academics.Class
  alias ModelCanaan.Accounts.User

  schema "students" do
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :admission_number, :string
    field :gender, :string
    field :date_of_birth, :date
    field :status, :string, default: "active"

    belongs_to :class, Class
    belongs_to :parent, User

    timestamps()
  end

  def changeset(student, attrs) do
    student
    |> cast(attrs, [
      :first_name,
      :middle_name,
      :last_name,
      :admission_number,
      :gender,
      :date_of_birth,
      :class_id,
      :parent_id,
      :status
    ])
    |> validate_required([:first_name, :last_name, :admission_number])
    |> unique_constraint(:admission_number)
    |> foreign_key_constraint(:class_id)
    |> foreign_key_constraint(:parent_id)
  end
end
