defmodule ModelCanaan.Academics.StudentRecordAccess do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModelCanaan.Accounts.User
  alias ModelCanaan.Academics.Student

  schema "student_record_access" do
    belongs_to :teacher, User
    belongs_to :student, Student
    belongs_to :granted_by, User
    field :status, :string, default: "active"

    timestamps()
  end

  def changeset(access, attrs) do
    access
    |> cast(attrs, [:teacher_id, :student_id, :granted_by_id, :status])
    |> validate_required([:teacher_id, :student_id])
    |> unique_constraint([:teacher_id, :student_id],
      message: "Teacher already has access to this student"
    )
  end
end
