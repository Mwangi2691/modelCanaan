defmodule ModelCanaan.Academics.Class do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classes" do
    field :name, :string
    field :stream, :string
    field :academic_year, :integer
    field :status, :string, default: "active"

    has_many :students, ModelCanaan.Academics.Student

    timestamps()
  end

  def changeset(class, attrs) do
    class
    |> cast(attrs, [:name, :stream, :academic_year, :status])
    |> validate_required([:name, :academic_year])
    |> unique_constraint([:name, :stream, :academic_year])
  end
end
