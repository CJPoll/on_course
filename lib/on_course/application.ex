defmodule OnCourse.Application do
  use Application

  import EPA

  def start(_type, _args) do
    import Supervisor.Spec

    required(["GITHUB_CLIENT_ID", "GITHUB_CLIENT_SECRET"], :dev)
    required(["SECRET_KEY_BASE"], :prod)

    children = [
      supervisor(OnCourse.Repo, []),
      supervisor(OnCourse.Web.Endpoint, []),
      supervisor(OnCourse.Quiz.Session.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: OnCourse.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
