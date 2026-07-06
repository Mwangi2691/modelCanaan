defmodule ModelCanaanWeb.UserController do
  use ModelCanaanWeb, :controller

  alias ModelCanaan.Accounts
  alias ModelCanaan.Accounts.User
  alias ModelCanaan.Repo

  plug :put_layout, {ModelCanaanWeb.Layouts, :admin}

  def index(conn, params) do
    search_term = Map.get(params, "search", "") |> String.trim()

    users =
      User
      |> Repo.all()
      |> Repo.preload(:roles)
      |> maybe_filter(search_term)

    render(conn, :index, users: users, search_value: search_term)
  end

  defp maybe_filter(users, ""), do: users

  defp maybe_filter(users, term) do
    term = String.downcase(term)

    Enum.filter(users, fn user ->
      String.contains?(String.downcase(Accounts.user_full_name(user)), term) or
        String.contains?(String.downcase(user.email || ""), term)
    end)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user_with_roles!(id)
    all_roles = Repo.all(ModelCanaan.Accounts.Role)
    assigned_role_ids = Enum.map(user.roles, & &1.id)

    render(conn, :show,
      user: user,
      all_roles: all_roles,
      assignable_roles: Enum.reject(all_roles, &(&1.id in assigned_role_ids))
    )
  end

  @doc "Attaches a role to this user. POST /admin/users/:id/roles"
  def assign_role(conn, %{"id" => user_id, "role_id" => role_id}) do
    user = Accounts.get_user!(user_id)
    role = Accounts.get_role!(role_id)

    case Accounts.assign_role(user, role) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "#{role.name} role assigned to #{Accounts.user_full_name(user)}.")
        |> redirect(to: ~p"/admin/users/#{user_id}")

      {:error, _} ->
        conn
        |> put_flash(:error, "Could not assign that role — they may already have it.")
        |> redirect(to: ~p"/admin/users/#{user_id}")
    end
  end

  @doc "Removes a role from this user. DELETE /admin/users/:user_id/roles/:role_id"
  def revoke_role(conn, %{"user_id" => user_id, "role_id" => role_id}) do
    user = Accounts.get_user!(user_id)
    role = Accounts.get_role!(role_id)

    Accounts.revoke_role(user, role)

    conn
    |> put_flash(:info, "#{role.name} role revoked from #{Accounts.user_full_name(user)}.")
    |> redirect(to: ~p"/admin/users/#{user_id}")
  end
end
