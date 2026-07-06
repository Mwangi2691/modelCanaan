defmodule ModelCanaan.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModelCanaan.Accounts.Role
  alias ModelCanaan.Accounts.UserRole

  schema "users" do
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :email, :string
    field :phone_number, :string
    field :gender, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :status, :string
    field :last_login_at, :utc_datetime

    many_to_many :roles, Role,
      join_through: UserRole,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :first_name,
      :middle_name,
      :last_name,
      :email,
      :phone_number,
      :gender,
      :password
    ])
    |> validate_length(:password, min: 8)
    |> validate_required([
      :first_name,
      :middle_name,
      :last_name,
      :email,
      :phone_number,
      :gender,
      :password
    ])
    |> hash_password()
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
  end

  def hash_password(changeset) do
    if password = get_change(changeset, :password) do
      change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
    else
      changeset
    end
  end
end
