# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :on_course,
  ecto_repos: [OnCourse.Repo]

dev_environment? =
  fn() ->
    case System.get_env("DEV_ENVIRONMENT") do
      "true" -> true
      _ -> false
    end
  end

watchers =
  if dev_environment?.() do
    [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
            cd: Path.expand("../assets", __DIR__)]]
  else
    []
  end

live_reload =
  if dev_environment?.() do
    [patterns: [
        ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
        ~r{priv/gettext/.*(po)$},
        ~r{lib/on_course/web/views/.*(ex)$},
        ~r{lib/on_course/web/templates/.*(eex)$}]]
  else
    []
  end

# Configures the endpoint
config :on_course, OnCourse.Web.Endpoint,
  url: [host: {:system, "HOST"}, port: {:system, "PORT"}],
  http: [port: {:system, "PORT"}],
  debug_errors: dev_environment?.(),
  code_reloader: dev_environment?.(),
  check_origin: !dev_environment?.(),
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: OnCourse.Web.ErrorView, accepts: ~w(html json)],
  watchers: watchers,
  pubsub: [name: OnCourse.PubSub,
           adapter: Phoenix.PubSub.PG2],
  live_reload: live_reload

if dev_environment?.() do
  config :phoenix, :stacktrace_depth, 20
end

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
  secret_key: System.get_env("SECRET_KEY"),
  serializer: OnCourse.GuardianSerializer

config :on_course, OnCourse.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATA_DB_USER"),
  password: System.get_env("DATA_DB_PASS"),
  hostname: System.get_env("DATA_DB_HOST"),
  database: System.get_env("DATA_DB_NAME"),
  pool_size: 2
