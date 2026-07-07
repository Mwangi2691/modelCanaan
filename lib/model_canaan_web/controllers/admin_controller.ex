defmodule ModelCanaanWeb.AdminController do
  use ModelCanaanWeb, :controller

  alias ModelCanaan.Accounts
  alias ModelCanaan.Accounts.Role
  alias ModelCanaan.Repo

  plug :put_layout, {ModelCanaanWeb.Layouts, :admin}

  def dashboard(conn, _params) do
    users = Accounts.list_users()
    role = Repo.preload(users, roles: :permissions)
    role_breakdown =
      Role
      |> Repo.all()
      |> Enum.map(fn role ->
        {role.name, length(Accounts.list_users_by_role(role.slug))}
      end)

    render(conn, :dashboard,
      user_count: length(Accounts.list_users()),
      role_breakdown: role_breakdown,
      users: users
    )
  end
end
