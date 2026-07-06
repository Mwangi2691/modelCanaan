defmodule ModelCanaanWeb.RegistrationController do
  use ModelCanaanWeb, :controller

  alias ModelCanaan.Accounts
  alias ModelCanaan.Accounts.User

  # def new(conn, _params) do
  #   changeset = User.changeset(%User{}, %{})

  #   render(conn, :new, changeset: changeset)
  # end
  def new(conn, _params) do
  changeset = Ecto.Changeset.change(%User{})

  render(conn, :new, changeset: changeset)
end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: "/login")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
