defmodule ModelCanaan.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ModelCanaanWeb.Telemetry,
      ModelCanaan.Repo,
      {DNSCluster, query: Application.get_env(:model_canaan, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ModelCanaan.PubSub},
      # Start a worker by calling: ModelCanaan.Worker.start_link(arg)
      # {ModelCanaan.Worker, arg},
      # Start to serve requests, typically the last entry
      ModelCanaanWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ModelCanaan.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ModelCanaanWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
