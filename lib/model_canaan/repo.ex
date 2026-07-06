defmodule ModelCanaan.Repo do
  use Ecto.Repo,
    otp_app: :model_canaan,
    adapter: Ecto.Adapters.Postgres
end
