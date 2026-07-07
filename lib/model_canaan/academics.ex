defmodule ModelCanaan.Academics do
  import Ecto.Query, warn: false

  alias ModelCanaan.Repo
  alias ModelCanaan.Accounts
  alias ModelCanaan.Accounts.User
  alias ModelCanaan.Academics.Class
  alias ModelCanaan.Academics.Student
  alias ModelCanaan.Academics.TeacherClassAssignment
  alias ModelCanaan.Academics.StudentRecordAccess
  alias ModelCanaan.Academics.Attendance
  alias ModelCanaan.Academics.TeacherReport

  ## Classes

  def list_classes, do: Repo.all(Class)
  def get_class!(id), do: Repo.get!(Class, id)

  def create_class(attrs) do
    %Class{}
    |> Class.changeset(attrs)
    |> Repo.insert()
  end

  ## Students — admission is a Principal action

  def list_students, do: Repo.all(Student) |> Repo.preload(:class)
  def get_student!(id), do: Repo.get!(Student, id) |> Repo.preload(:class)

  @doc """
  Admits a new student. `principal` must hold the "principal" role — this is
  the enforcement point, not a DB constraint, so it stays visible and testable.
  """
  def admit_student(%User{} = principal, attrs) do
    if Accounts.has_role?(principal, "principal") do
      %Student{}
      |> Student.changeset(attrs)
      |> Repo.insert()
    else
      {:error, :not_authorized}
    end
  end

  ## Teacher ↔ Class — assignment is a Principal action

  @doc """
  Assigns a teacher to a class. Only a principal may do this.
  """
  def assign_teacher_to_class(%User{} = principal, %User{} = teacher, %Class{} = class) do
    cond do
      not Accounts.has_role?(principal, "principal") ->
        {:error, :not_authorized}

      not Accounts.has_role?(teacher, "teacher") ->
        {:error, :not_a_teacher}

      true ->
        %TeacherClassAssignment{}
        |> TeacherClassAssignment.changeset(%{
          teacher_id: teacher.id,
          class_id: class.id,
          assigned_by_id: principal.id
        })
        |> Repo.insert()
    end
  end

  def list_classes_for_teacher(%User{} = teacher) do
    Class
    |> join(:inner, [c], a in TeacherClassAssignment,
      on: a.class_id == c.id and a.teacher_id == ^teacher.id and a.status == "active"
    )
    |> Repo.all()
  end

  def teacher_assigned_to_class?(%User{} = teacher, class_id) do
    TeacherClassAssignment
    |> where(
      [a],
      a.teacher_id == ^teacher.id and a.class_id == ^class_id and a.status == "active"
    )
    |> Repo.exists?()
  end

  ## Teacher ↔ Student record access — granted by Admin, gated on the
  ## Principal's class assignment already existing

  @doc """
  Grants a teacher access to a specific student's records.

  Requires:
  - `admin` holds the "admin" role
  - the teacher is already assigned (by a principal) to that student's class

  This is the dependency you described: admin can only open the door the
  principal already built.
  """
  def grant_student_access(%User{} = admin, %User{} = teacher, %Student{} = student) do
    cond do
      not Accounts.has_role?(admin, "admin") ->
        {:error, :not_authorized}

      is_nil(student.class_id) ->
        {:error, :student_has_no_class}

      not teacher_assigned_to_class?(teacher, student.class_id) ->
        {:error, :teacher_not_assigned_to_class}

      true ->
        %StudentRecordAccess{}
        |> StudentRecordAccess.changeset(%{
          teacher_id: teacher.id,
          student_id: student.id,
          granted_by_id: admin.id
        })
        |> Repo.insert()
    end
  end

  def revoke_student_access(%User{} = teacher, %Student{} = student) do
    StudentRecordAccess
    |> where([a], a.teacher_id == ^teacher.id and a.student_id == ^student.id)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      access -> Repo.delete(access)
    end
  end

  def teacher_has_student_access?(%User{} = teacher, student_id) do
    StudentRecordAccess
    |> where(
      [a],
      a.teacher_id == ^teacher.id and a.student_id == ^student_id and a.status == "active"
    )
    |> Repo.exists?()
  end

  @doc "Every student a teacher currently has explicit record access to."
  def list_accessible_students(%User{} = teacher) do
    Student
    |> join(:inner, [s], a in StudentRecordAccess,
      on: a.student_id == s.id and a.teacher_id == ^teacher.id and a.status == "active"
    )
    |> Repo.all()
    |> Repo.preload(:class)
  end

  ## Attendance — a teacher may only mark it for students they have
  ## explicit record access to (StudentRecordAccess, granted by admin)

  def mark_attendance(%User{} = teacher, %Student{} = student, attrs) do
    if teacher_has_student_access?(teacher, student.id) do
      %Attendance{}
      |> Attendance.changeset(
        Map.merge(attrs, %{
          "student_id" => student.id,
          "class_id" => student.class_id,
          "teacher_id" => teacher.id
        })
      )
      |> Repo.insert()
    else
      {:error, :not_authorized}
    end
  end

  def list_attendance_for_student(%Student{} = student) do
    Attendance
    |> where([a], a.student_id == ^student.id)
    |> order_by([a], desc: a.date)
    |> Repo.all()
  end

  ## Reports — a teacher submits one per class they're assigned to;
  ## a principal reviews all of them

  def submit_report(%User{} = teacher, %Class{} = class, attrs) do
    if teacher_assigned_to_class?(teacher, class.id) do
      %TeacherReport{}
      |> TeacherReport.changeset(
        Map.merge(attrs, %{"teacher_id" => teacher.id, "class_id" => class.id})
      )
      |> Repo.insert()
    else
      {:error, :not_authorized}
    end
  end

  @doc "All reports across all classes — for the principal's review queue."
  def list_reports do
    TeacherReport
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
    |> Repo.preload([:teacher, :class])
  end

  def list_reports_for_teacher(%User{} = teacher) do
    TeacherReport
    |> where([r], r.teacher_id == ^teacher.id)
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
    |> Repo.preload(:class)
  end

  def get_report!(id), do: Repo.get!(TeacherReport, id) |> Repo.preload([:teacher, :class])

  def mark_report_reviewed(%User{} = principal, %TeacherReport{} = report) do
    if Accounts.has_role?(principal, "principal") do
      report
      |> TeacherReport.review_changeset(%{
        reviewed_by_id: principal.id,
        reviewed_at: DateTime.utc_now() |> DateTime.truncate(:second),
        status: "reviewed"
      })
      |> Repo.update()
    else
      {:error, :not_authorized}
    end
  end
end
