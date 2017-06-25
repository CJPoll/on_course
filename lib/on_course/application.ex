defmodule OnCourse.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(OnCourse.Repo, []),
      supervisor(OnCourse.Web.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: OnCourse.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
