defmodule ModelCanaan.Accounts do
  import Ecto.Query, warn: false

  alias ModelCanaan.Repo
  alias ModelCanaan.Accounts.User
  alias ModelCanaan.Accounts.Role
  alias ModelCanaan.Accounts.UserRole
  alias ModelCanaan.Accounts.Role

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, Repo.preload(user, roles: :permissions)}

      true ->
        {:error, :invalid_credentials}
    end
  end

  def get_user(id), do: Repo.get(User, id)

  def get_role!(id), do: Repo.get!(Role, id)
  def get_user!(id), do: Repo.get!(User, id)

  def list_users do
    User
    |> order_by([u], desc: u.inserted_at)
    |> Repo.all()
  end

  def get_user_with_roles!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(roles: :permissions)
  end

  def list_users_by_role(role_slug) do
    User
    |> join(:inner, [u], r in assoc(u, :roles))
    |> where([u, r], r.slug == ^role_slug)
    |> order_by([u], desc: u.inserted_at)
    |> Repo.all()
  end

  @doc "Attaches a role to a user (many-to-many; a user can hold several roles)."
  def assign_role(%User{} = user, %Role{} = role) do
    %UserRole{}
    |> UserRole.changeset(%{user_id: user.id, role_id: role.id})
    |> Repo.insert()
  end

  def assign_role(%User{} = user, role_slug) when is_binary(role_slug) do
    case Repo.get_by(Role, slug: role_slug) do
      nil -> {:error, :role_not_found}
      role -> assign_role(user, role)
    end
  end

  @doc "Detaches a role from a user."
  def revoke_role(%User{} = user, %Role{} = role) do
    case UserRole.get_user_role(user.id, role.id) do
      nil -> {:error, :not_found}
      user_role -> Repo.delete(user_role)
    end
  end

  @doc "Returns true if the user holds a role with this slug."
  def has_role?(%User{} = user, role_slug) do
    user = Repo.preload(user, :roles)
    Enum.any?(user.roles, &(&1.slug == role_slug))
  end

  @doc "Returns true if any of the user's roles grants this permission slug."
  def has_permission?(%User{} = user, permission_slug) do
    user = Repo.preload(user, roles: :permissions)

    user.roles
    |> Enum.flat_map(& &1.permissions)
    |> Enum.any?(&(&1.slug == permission_slug))
  end

  def user_full_name(%User{} = user) do
    [user.first_name, user.middle_name, user.last_name]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join(" ")
  end
end
