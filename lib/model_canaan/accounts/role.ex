defmodule ModelCanaan.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias ModelCanaan.Repo
  alias ModelCanaan.Accounts.Permission
  alias ModelCanaan.Accounts.RolePermission

  @active "active"

  schema "roles" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :type, :string
    field :status, :string, default: @active

    many_to_many :permissions, Permission,
      join_through: RolePermission,
      on_replace: :delete

    timestamps()
  end

  def changeset(%__MODULE__{} = role, attrs \\ %{}) do
    role
    |> cast(attrs, [:name, :slug, :description, :type, :status])
    |> validate_required([:name])
    |> unique_constraint(:name, message: "Role already exists")
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> put_valid_permissions(Map.get(attrs, "permission_ids", []))
    |> Repo.insert()
  end

  def update(%__MODULE__{} = role, attrs) do
    role
    |> changeset(attrs)
    |> put_valid_permissions(Map.get(attrs, "permission_ids", []))
    |> Repo.update()
  end

  defp put_valid_permissions(changeset, permission_ids) do
    permission_ids =
      permission_ids
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&to_integer/1)

    permissions =
      Permission
      |> where([p], p.id in ^permission_ids)
      |> Repo.all()

    put_assoc(changeset, :permissions, permissions)
  end

  defp to_integer(id) when is_binary(id), do: String.to_integer(id)
  defp to_integer(id) when is_integer(id), do: id

def preload_permissions(%__MODULE__{} = role), do: Repo.preload(role, :permissions)

def preload_permissions(roles) when is_list(roles), do: Repo.preload(roles, :permissions)

def preload_permissions(queryable) do
  from(r in queryable, preload: [:permissions])
end
end
