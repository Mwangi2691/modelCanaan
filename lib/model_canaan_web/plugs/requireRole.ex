defmodule ModelCanaanWeb.Plugs.RequireRole do
  @moduledoc """
  Blocks the request unless conn.assigns.current_user holds the given role slug.

  Usage in a router pipeline:

      pipeline :require_admin do
        plug ModelCanaanWeb.Plugs.RequireRole, "admin"
      end

  Or directly in a controller:

      plug ModelCanaanWeb.Plugs.RequireRole, "admin"
  """
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias ModelCanaan.Accounts

  def init(role_slug), do: role_slug

  def call(conn, role_slug) do
    user = conn.assigns[:current_user]

    cond do
      is_nil(user) ->
        conn
        |> put_flash(:error, "Please log in to continue.")
        |> redirect(to: "/login")
        |> halt()

      Accounts.has_role?(user, role_slug) ->
        conn

      true ->
        conn
        |> put_flash(:error, "You don't have access to that page.")
        |> redirect(to: "/")
        |> halt()
    end
  end
end

defmodule ModelCanaanWeb.Plugs.RequirePermission do
  @moduledoc """
  Blocks the request unless conn.assigns.current_user has the given permission
  slug (e.g. "write_grades") through any of their roles.

  Usage:

      plug ModelCanaanWeb.Plugs.RequirePermission, "write_grades"
  """
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias ModelCanaan.Accounts

  def init(permission_slug), do: permission_slug

  def call(conn, permission_slug) do
    user = conn.assigns[:current_user]

    cond do
      is_nil(user) ->
        conn
        |> put_flash(:error, "Please log in to continue.")
        |> redirect(to: "/login")
        |> halt()

      Accounts.has_permission?(user, permission_slug) ->
        conn

      true ->
        conn
        |> put_flash(:error, "You don't have permission to do that.")
        |> redirect(to: "/")
        |> halt()
    end
  end
end
