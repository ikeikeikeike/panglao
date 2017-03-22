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

config :panglao, :redis,
  lock_in_task: "redis://127.0.0.1:6379/2"

config :panglao, :convert,
  encode: false

config :panglao, Panglao.Gettext,
  default_locale: "ja",
  locales: ~w(en es ja)

config :exq,
  name: Exq,
  host: "127.0.0.1",
  port: 6379,
  database: 1,
  namespace: "exq",
  queues: [{"default", :infinite}, {"encoder", 1}],
  scheduler_enable: true,
  max_retries: 15
  # password: "optional_redis_auth",
  # poll_timeout: 50,
  # scheduler_poll_timeout: 200,
  # shutdown_timeout: 5000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
import_config "#{Mix.env}.secret.exs"
import_config "schedule.#{Mix.env}.exs"
import_config "consts.secret.exs"
