defmodule OnCourse.Mixfile do
  use Mix.Project

  def project do
    [app: :on_course,
     version: "0.0.1",
     elixir: "~> 1.5",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     dialyzer: [plt_add_deps: :app_direct, ignore_warnings: "dialyzer.ignore-warnings"],
     deps: deps()]
  end

  def application do
    [mod: {OnCourse.Application, []},
     extra_applications: extra_applications(Mix.env)]
  end

  def extra_applications(:test), do: [:ueberauth_github, :logger, :runtime_tools, :ex_unit, :crypto]
  def extra_applications(_), do: [:ueberauth_github, :logger, :runtime_tools, :crypto]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [{:cowboy, "~> 1.0"},
     {:ectoplasm, "~> 0.2.0"},
     {:epa, "~> 0.1.0"},
     {:gettext, "~> 0.11"},
     {:guardian, "~> 0.14.0"},
     {:phoenix, "~> 1.3.0"},
     {:phoenix_ecto, "~> 3.2"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:phoenix_pubsub, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     {:ueberauth_github, "~> 0.4"},
     {:uuid, "~> 1.1.0"}
    ]
  end

  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "compile": ["compile --warnings-as-errors"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test", "dialyzer --halt-exit-status"]]
  end
end
