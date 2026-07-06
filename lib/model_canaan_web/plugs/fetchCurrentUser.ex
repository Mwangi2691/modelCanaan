defmodule ModelCanaanWeb.Plugs.FetchCurrentUser do
  @moduledoc """
  Loads the logged-in user (with roles/permissions preloaded) from the
  session into conn.assigns.current_user. Put this in your :browser
  pipeline, before any RequireRole/RequirePermission plugs.
  """
  import Plug.Conn

  alias ModelCanaan.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :user_id) do
      nil ->
        assign(conn, :current_user, nil)

      user_id ->
        user = Accounts.get_user_with_roles!(user_id)
        assign(conn, :current_user, user)
    end
  end
end
