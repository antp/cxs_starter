# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :cxs_starter,
  ecto_repos: [CxsStarter.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :cxs_starter, CxsStarterWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "IRfpNNtxdwWL0NA509Nu1gZVbIJr4alh9sOi/kEbRiw8ObKdjLbTLtFiLTVXPbqY",
  render_errors: [view: CxsStarterWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CxsStarter.PubSub,
  live_view: [signing_salt: "Pl9EtVWh"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
