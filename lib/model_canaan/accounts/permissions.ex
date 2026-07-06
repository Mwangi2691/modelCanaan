defmodule ModelCanaan.Accounts.Permission do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias ModelCanaan.Repo

  @active "active"

  schema "permissions" do
    field :name, :string
    field :slug, :string
    field :action, :string
    field :resource, :string
    field :status, :string, default: @active

    timestamps()
  end

  def changeset(%__MODULE__{} = permission, attrs \\ %{}) do
    permission
    |> cast(attrs, [:name, :slug, :action, :resource, :status])
    |> validate_required([:name, :action, :resource])
    |> unique_constraint([:name, :action, :resource], message: "Permission already exists")
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def update(%__MODULE__{} = permission, attrs) do
    permission
    |> changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Seeds the school's baseline permissions (resource x action).
  Call from priv/repo/seeds.exs: ModelCanaan.Accounts.Permission.permission_seeds()
  """
  def permission_seeds do
    resources = ["students", "grades", "attendance", "fees", "reports", "users", "dashboard"]
    actions = ["read", "write"]

    all_permissions =
      for resource <- resources, action <- actions do
        slug = "#{action}_#{resource}"

        name =
          "#{String.capitalize(action)} #{resource |> String.replace("_", " ") |> String.capitalize()}"

        %{
          name: name,
          slug: slug,
          action: action,
          resource: resource,
          status: "active",
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        }
      end

    existing_slugs = Repo.all(from(p in __MODULE__, select: p.slug))

    new_permissions = Enum.reject(all_permissions, &(&1.slug in existing_slugs))

    case new_permissions do
      [] -> IO.puts("✓ No new permissions to insert")
      _ ->
        {count, _} = Repo.insert_all(__MODULE__, new_permissions)
        IO.puts("✓ Inserted #{count} new permissions")
    end
  end
end
