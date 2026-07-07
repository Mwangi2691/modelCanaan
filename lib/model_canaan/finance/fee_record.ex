defmodule ModelCanaan.Finance.FeeRecord do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModelCanaan.Academics.Student

  schema "fee_records" do
    belongs_to :student, Student
    field :academic_year, :integer
    field :term, :string
    field :amount_due, :decimal
    field :amount_paid, :decimal, default: 0.0
    field :status, :string, default: "unpaid"

    timestamps()
  end

  def changeset(fee_record, attrs) do
    fee_record
    |> cast(attrs, [:student_id, :academic_year, :term, :amount_due, :amount_paid, :status])
    |> validate_required([:student_id, :academic_year, :term, :amount_due])
    |> unique_constraint([:student_id, :academic_year, :term])
    |> put_status()
  end

  defp put_status(changeset) do
    due = get_field(changeset, :amount_due) || Decimal.new(0)
    paid = get_field(changeset, :amount_paid) || Decimal.new(0)

    status =
      cond do
        Decimal.compare(paid, due) != :lt -> "paid"
        Decimal.compare(paid, 0) == :gt -> "partial"
        true -> "unpaid"
      end

    put_change(changeset, :status, status)
  end
end
