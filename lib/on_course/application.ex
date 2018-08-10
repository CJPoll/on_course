defmodule OnCourse.Application do
  use Application

  import EPA

  def start(_type, _args) do
    import Supervisor.Spec

    required(["HOST", "PORT", "SECRET_KEY_BASE", "SECRET_KEY", "GITHUB_CLIENT_ID", "GITHUB_CLIENT_SECRET"])

    children = [
      supervisor(OnCourse.Repo, []),
      supervisor(OnCourse.Web.Endpoint, []),
      supervisor(OnCourse.Quizzes.Session.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: OnCourse.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
