use Mix.Config

alias OnCourse.Config

config :on_course, OnCourse.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: System.get_env("DATA_DB_USER"),
  password: System.get_env("DATA_DB_PASS"),
  hostname: System.get_env("DATA_DB_HOST"),
  database: System.get_env("DATA_DB_NAME"),
  pool_size: 2
