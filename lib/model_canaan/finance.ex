defmodule ModelCanaan.Finance do
  import Ecto.Query, warn: false

  alias ModelCanaan.Repo
  alias ModelCanaan.Accounts
  alias ModelCanaan.Accounts.User
  alias ModelCanaan.Academics.Student
  alias ModelCanaan.Finance.FeeRecord

  @doc """
  Fee records are sensitive — only admin or principal can view them here.
  (Parents see their own child's record through a separate, narrower
  parent-facing function you can add later.)
  """
  def list_fee_records_for_student(%User{} = viewer, %Student{} = student) do
    if Accounts.has_role?(viewer, "admin") or Accounts.has_role?(viewer, "principal") do
      FeeRecord
      |> where([f], f.student_id == ^student.id)
      |> order_by([f], desc: f.academic_year, desc: f.term)
      |> Repo.all()
    else
      {:error, :not_authorized}
    end
  end

  def create_fee_record(attrs) do
    %FeeRecord{}
    |> FeeRecord.changeset(attrs)
    |> Repo.insert()
  end

  def record_payment(%FeeRecord{} = fee_record, amount_paid) do
    new_total = Decimal.add(fee_record.amount_paid, amount_paid)

    fee_record
    |> FeeRecord.changeset(%{"amount_paid" => new_total})
    |> Repo.update()
  end
end
