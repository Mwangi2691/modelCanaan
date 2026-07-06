defmodule ModelCanaanWeb.SessionController do
  use ModelCanaanWeb, :controller

  alias ModelCanaan.Accounts

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password} = session_params}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> maybe_remember_me(session_params)
        |> put_flash(:info, "Welcome back, #{user.first_name}!")
        |> redirect(to: dashboard_path(user))

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Invalid email or password. Please try again.")
        |> render(:new)

      # {:error, :user_not_found} ->
      #   conn
      #   |> put_flash(:error, "Invalid email or password")
      #   |> render(:new)
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: ~p"/")
  end

  defp dashboard_path(user) do
  cond do
    Enum.any?(user.roles, &(&1.slug == "admin")) ->
      ~p"/admin/dashboard"

    Enum.any?(user.roles, &(&1.slug == "teacher")) ->
      ~p"/teacher/dashboard"

    Enum.any?(user.roles, &(&1.slug == "parent")) ->
      ~p"/parent/dashboard"

    true ->
      ~p"/"
  end
end

  defp maybe_remember_me(conn, %{"remember_me" => "true"}) do
    put_session(conn, :remember_me, true)
  end

  defp maybe_remember_me(conn, _), do: conn
end
