defmodule ModelCanaanWeb.Plugs.Auth do
  import Plug.Conn
  import Phoenix.Controller

  alias ModelCanaan.Accounts

  def init(opts), do: opts



  def call(conn, _opts) do
  user_id = get_session(conn, :user_id)

  user =
    if user_id do
      Accounts.get_user_with_roles!(user_id)
    end

  assign(conn, :current_user, user)
end

  # Call this in protected pipelines to block unauthenticated access
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access this page.")
      |> redirect(to: "/login")
      |> halt()
    end
  end

  # Role-based guard — pass role as string e.g. "admin"
  def require_role(conn, role_slug) do
    user = conn.assigns[:current_user]


  if user &&
       Enum.any?(user.roles, &(&1.slug == role_slug)) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorised to access this page.")
      |> redirect(to: "/")
      |> halt()
    end
  end
#   def require_role(conn, role_slug) do
#   user = conn.assigns[:current_user]

#   if user &&
#        Enum.any?(user.roles, &(&1.slug == role_slug)) do
#     conn
#   else
#     conn
#     |> put_flash(:error, "You are not authorised to access this page.")
#     |> redirect(to: ~p"/login")
#     |> halt()
#   end
# end
end
