# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :on_course,
  ecto_repos: [OnCourse.Repo]

watchers =
  if System.get_env("MIX_ENV") == "dev" do
    [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
            cd: Path.expand("../assets", __DIR__)]]
  else
    []
  end

# Configures the endpoint
config :on_course, OnCourse.Web.Endpoint,
  url: [host: {:system, "HOST"}, port: {:system, "PORT"}],
  http: [port: {:system, "PORT"}],
  debug_errors: System.get_env("MIX_ENV") == "dev",
  code_reloader: System.get_env("MIX_ENV") == "dev",
  check_origin: System.get_env("MIX_ENV") == "prod",
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: OnCourse.Web.ErrorView, accepts: ~w(html json)],
  watchers: watchers,
  pubsub: [name: OnCourse.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  providers: [
      github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "OnCourse",
  ttl: { 30, :days  },
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "gQfrBbbYqTmQ9mlYJPMGOs4veWCjb4nbShci6qAcVfaB9VNSZohuZ2BsfwRykN10",
  serializer: OnCourse.GuardianSerializer

config :on_course, OnCourse.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATA_DB_USER"),
  password: System.get_env("DATA_DB_PASS"),
  hostname: System.get_env("DATA_DB_HOST"),
  database: System.get_env("DATA_DB_NAME"),
  pool_size: 10

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
