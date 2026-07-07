defmodule ModelCanaan.Academics.TeacherReport do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModelCanaan.Academics.Class
  alias ModelCanaan.Accounts.User

  schema "teacher_reports" do
    belongs_to :teacher, User
    belongs_to :class, Class
    field :title, :string
    field :content, :string
    field :status, :string, default: "submitted"
    belongs_to :reviewed_by, User
    field :reviewed_at, :utc_datetime

    timestamps()
  end

  def changeset(report, attrs) do
    report
    |> cast(attrs, [:teacher_id, :class_id, :title, :content, :status])
    |> validate_required([:teacher_id, :class_id, :title, :content])
  end

  def review_changeset(report, attrs) do
    report
    |> cast(attrs, [:reviewed_by_id, :reviewed_at, :status])
    |> validate_required([:reviewed_by_id])
  end
end
