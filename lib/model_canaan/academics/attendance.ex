defmodule ModelCanaan.Academics.Attendance do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModelCanaan.Academics.{Student, Class}
  alias ModelCanaan.Accounts.User

  schema "attendance_records" do
    belongs_to :student, Student
    belongs_to :class, Class
    belongs_to :teacher, User
    field :date, :date
    field :status, :string
    field :remarks, :string

    timestamps()
  end

  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [:student_id, :class_id, :teacher_id, :date, :status, :remarks])
    |> validate_required([:student_id, :class_id, :teacher_id, :date, :status])
    |> validate_inclusion(:status, ["present", "absent", "late"])
    |> unique_constraint([:student_id, :date],
      message: "Attendance already recorded for this student today"
    )
  end
end
