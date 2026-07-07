defmodule ModelCanaanWeb.TeacherController do
  use ModelCanaanWeb, :controller

  alias ModelCanaan.Academics

  plug :put_layout, {ModelCanaanWeb.Layouts, :teacher}

  def dashboard(conn, _params) do
    teacher = conn.assigns.current_user
    classes = Academics.list_classes_for_teacher(teacher)
    students = Academics.list_accessible_students(teacher)

    render(conn, :dashboard, classes: classes, students: students)
  end

  @doc """
  Shows one student's record — but only if this teacher has been explicitly
  granted access (by admin, downstream of the principal's class assignment).
  """
  def show_student(conn, %{"id" => id}) do
    teacher = conn.assigns.current_user
    student = Academics.get_student!(id)

    if Academics.teacher_has_student_access?(teacher, student.id) do
      attendance = Academics.list_attendance_for_student(student)
      render(conn, :show_student, student: student, attendance: attendance)
    else
      conn
      |> put_flash(:error, "You don't have access to this student's records.")
      |> redirect(to: ~p"/teacher/dashboard")
    end
  end

  def mark_attendance(conn, %{"id" => student_id, "status" => status} = params) do
    teacher = conn.assigns.current_user
    student = Academics.get_student!(student_id)

    attrs = %{
      "date" => Map.get(params, "date", Date.utc_today() |> Date.to_string()),
      "status" => status,
      "remarks" => Map.get(params, "remarks", "")
    }

    case Academics.mark_attendance(teacher, student, attrs) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Attendance recorded.")
        |> redirect(to: ~p"/teacher/students/#{student_id}")

      {:error, :not_authorized} ->
        conn
        |> put_flash(:error, "You don't have access to this student.")
        |> redirect(to: ~p"/teacher/dashboard")

      {:error, changeset} ->
        errors = changeset.errors |> Enum.map(fn {_, {msg, _}} -> msg end) |> Enum.join(", ")

        conn
        |> put_flash(:error, "Could not record attendance: #{errors}")
        |> redirect(to: ~p"/teacher/students/#{student_id}")
    end
  end

  def new_report(conn, %{"id" => class_id}) do
    render(conn, :new_report, class_id: class_id)
  end

  def create_report(conn, %{"id" => class_id, "title" => title, "content" => content}) do
    teacher = conn.assigns.current_user
    class = Academics.get_class!(class_id)

    case Academics.submit_report(teacher, class, %{"title" => title, "content" => content}) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Report submitted to the principal.")
        |> redirect(to: ~p"/teacher/dashboard")

      {:error, :not_authorized} ->
        conn
        |> put_flash(:error, "You're not assigned to this class.")
        |> redirect(to: ~p"/teacher/dashboard")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not submit report.")
        |> redirect(to: ~p"/teacher/classes/#{class_id}/report/new")
    end
  end
end
