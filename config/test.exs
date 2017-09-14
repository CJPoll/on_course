use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :on_course, OnCourse.Web.Endpoint,
  http: [port: 4001],
  server: false

config :ectoplasm, repository: OnCourse.Repo

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :on_course, OnCourse.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATA_DB_USER"),
  password: System.get_env("DATA_DB_PASS"),
  hostname: System.get_env("DATA_DB_HOST"),
  database: "on_course_test",
  pool: Ecto.Adapters.SQL.Sandbox

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
