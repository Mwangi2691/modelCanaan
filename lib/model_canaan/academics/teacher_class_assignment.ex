defmodule ModelCanaan.Academics.TeacherClassAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModelCanaan.Accounts.User
  alias ModelCanaan.Academics.Class

  schema "teacher_class_assignments" do
    belongs_to :teacher, User
    belongs_to :class, Class
    belongs_to :assigned_by, User
    field :status, :string, default: "active"

    timestamps()
  end

  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [:teacher_id, :class_id, :assigned_by_id, :status])
    |> validate_required([:teacher_id, :class_id])
    |> unique_constraint([:teacher_id, :class_id],
      message: "Teacher is already assigned to this class"
    )
  end
end 
