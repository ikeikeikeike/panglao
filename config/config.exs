# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :panglao,
  ecto_repos: [Panglao.Repo]

# Configures the endpoint
config :panglao, Panglao.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/yUMXUBYRqnAevm1vSQ18m+Yz7oedhqOF5oq0T4jn2xUYQGqFk3iKASEh+yfGS1x",
  render_errors: [view: Panglao.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Panglao.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ua_inspector,
  database_path: Path.join(File.cwd!, "config/ua_inspector")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
