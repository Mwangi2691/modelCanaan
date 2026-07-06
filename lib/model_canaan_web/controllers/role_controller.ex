defmodule ModelCanaanWeb.RoleController do
  use ModelCanaanWeb, :controller

  alias ModelCanaan.Repo
  alias ModelCanaan.Accounts
  alias ModelCanaan.Accounts.Role
  alias ModelCanaan.Accounts.Permission

  plug :put_layout, {ModelCanaanWeb.Layouts, :admin}

  @doc "Lists all roles and permissions — the RBAC overview page."
  def index(conn, _params) do
    roles = Repo.all(Role) |> Role.preload_permissions()
    permissions = Repo.all(Permission)

    render(conn, :index,
      roles: roles,
      permissions: permissions,
      role_count: length(roles),
      permission_count: length(permissions)
    )
  end

  def new(conn, _params) do
    render(conn, :new,
      changeset: Role.changeset(%Role{}),
      permissions: Repo.all(Permission)
    )
  end

  def create(conn, %{"role" => params}) do
    case Role.create(params) do
      {:ok, _role} ->
        conn
        |> put_flash(:info, "Role created successfully.")
        |> redirect(to: ~p"/admin/roles")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Could not create role.")
        |> render(:new, changeset: changeset, permissions: Repo.all(Permission))
    end
  end

  def edit(conn, %{"id" => id}) do
    role = Accounts.get_role!(id) |> Role.preload_permissions()
    selected_permission_ids = Enum.map(role.permissions, & &1.id)

    render(conn, :edit,
      id: id,
      changeset: Role.changeset(role),
      permissions: Repo.all(Permission),
      selected_permission_ids: selected_permission_ids
    )
  end

  def update(conn, %{"id" => id, "role" => params}) do
    role = Accounts.get_role!(id) |> Role.preload_permissions()

    case Role.update(role, params) do
      {:ok, _role} ->
        conn
        |> put_flash(:info, "Role updated successfully.")
        |> redirect(to: ~p"/admin/roles")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Could not update role.")
        |> render(:edit, id: id, changeset: changeset, permissions: Repo.all(Permission))
    end
  end

  @doc "Attaches a role to a user, e.g. POST /admin/users/:id/roles with role_id param."
  def assign_role(conn, %{"id" => user_id, "role_id" => role_id}) do
    user = Accounts.get_user!(user_id)
    role = Accounts.get_role!(role_id)

    case Accounts.assign_role(user, role) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Role assigned.")
        |> redirect(to: ~p"/admin/users/#{user_id}")

      {:error, _} ->
        conn
        |> put_flash(:error, "Could not assign role — user may already have it.")
        |> redirect(to: ~p"/admin/users/#{user_id}")
    end
  end

  def revoke_role(conn, %{"user_id" => user_id, "role_id" => role_id}) do
    user = Accounts.get_user!(user_id)
    role = Accounts.get_role!(role_id)

    Accounts.revoke_role(user, role)

    conn
    |> put_flash(:info, "Role revoked.")
    |> redirect(to: ~p"/admin/users/#{user_id}")
  end
end
