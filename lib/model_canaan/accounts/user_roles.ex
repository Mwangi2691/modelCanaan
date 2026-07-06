defmodule ModelCanaan.Accounts.UserRole do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias ModelCanaan.Repo
  alias ModelCanaan.Accounts.User
  alias ModelCanaan.Accounts.Role

  schema "user_roles" do
    belongs_to :user, User
    belongs_to :role, Role

    timestamps()
  end

  def changeset(%__MODULE__{} = user_role, attrs \\ %{}) do
    user_role
    |> cast(attrs, [:user_id, :role_id])
    |> validate_required([:user_id, :role_id])
    |> unique_constraint([:user_id, :role_id], message: "User already has this role")
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def get_user_role(user_id, role_id) do
    __MODULE__
    |> where([ur], ur.user_id == ^user_id and ur.role_id == ^role_id)
    |> Repo.one()
  end
end
