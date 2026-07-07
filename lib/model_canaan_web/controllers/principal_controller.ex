defmodule ModelCanaanWeb.PrincipalController do
  use ModelCanaanWeb, :controller

  alias ModelCanaan.Academics
  alias ModelCanaan.Finance
  alias ModelCanaan.Accounts

  plug :put_layout, {ModelCanaanWeb.Layouts, :principal}

  def dashboard(conn, _params) do
    render(conn, :dashboard,
      class_count: length(Academics.list_classes()),
      student_count: length(Academics.list_students()),
      report_count: length(Academics.list_reports())
    )
  end

  ## Admitting students

  def new_student(conn, _params) do
    render(conn, :new_student, classes: Academics.list_classes())
  end

  def create_student(conn, %{"student" => params}) do
    principal = conn.assigns.current_user

    case Academics.admit_student(principal, params) do
      {:ok, student} ->
        conn
        |> put_flash(:info, "#{student.first_name} #{student.last_name} admitted successfully.")
        |> redirect(to: ~p"/principal/dashboard")

      {:error, :not_authorized} ->
        conn
        |> put_flash(:error, "You don't have permission to admit students.")
        |> redirect(to: ~p"/principal/dashboard")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not admit student — check the admission number is unique.")
        |> render(:new_student, classes: Academics.list_classes())
    end
  end

  ## Assigning teachers to classes

  def new_assignment(conn, _params) do
    render(conn, :new_assignment,
      teachers: Accounts.list_users_by_role("teacher"),
      classes: Academics.list_classes()
    )
  end

  def create_assignment(conn, %{"teacher_id" => teacher_id, "class_id" => class_id}) do
    principal = conn.assigns.current_user
    teacher = Accounts.get_user!(teacher_id)
    class = Academics.get_class!(class_id)

    case Academics.assign_teacher_to_class(principal, teacher, class) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "#{Accounts.user_full_name(teacher)} assigned to #{class.name}.")
        |> redirect(to: ~p"/principal/dashboard")

      {:error, :not_a_teacher} ->
        conn
        |> put_flash(:error, "That user doesn't hold the Teacher role.")
        |> redirect(to: ~p"/principal/assignments/new")

      {:error, _} ->
        conn
        |> put_flash(:error, "Could not create that assignment — it may already exist.")
        |> redirect(to: ~p"/principal/assignments/new")
    end
  end

  ## Reports submitted by class teachers

  def reports(conn, _params) do
    render(conn, :reports, reports: Academics.list_reports())
  end

  def review_report(conn, %{"id" => id}) do
    principal = conn.assigns.current_user
    report = Academics.get_report!(id)

    case Academics.mark_report_reviewed(principal, report) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Report marked as reviewed.")
        |> redirect(to: ~p"/principal/reports")

      {:error, _} ->
        conn
        |> put_flash(:error, "Could not update this report.")
        |> redirect(to: ~p"/principal/reports")
    end
  end

  ## Financial records per student

  def student_finance(conn, %{"id" => id}) do
    principal = conn.assigns.current_user
    student = Academics.get_student!(id)

    case Finance.list_fee_records_for_student(principal, student) do
      {:error, :not_authorized} ->
        conn
        |> put_flash(:error, "Not authorized to view financial records.")
        |> redirect(to: ~p"/principal/dashboard")

      fee_records ->
        render(conn, :student_finance, student: student, fee_records: fee_records)
    end
  end
end
