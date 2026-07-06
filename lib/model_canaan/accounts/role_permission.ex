defmodule ModelCanaan.Accounts.RolePermission do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModelCanaan.Repo
  alias ModelCanaan.Accounts.Role
  alias ModelCanaan.Accounts.Permission

  schema "role_permissions" do
    belongs_to :role, Role
    belongs_to :permission, Permission

    timestamps()
  end

  def changeset(%__MODULE__{} = role_permission, attrs) do
    role_permission
    |> cast(attrs, [:role_id, :permission_id])
    |> validate_required([:role_id, :permission_id])
    |> unique_constraint([:role_id, :permission_id], message: "Role already has this permission")
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
