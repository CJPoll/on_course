defmodule OnCourse.Repo do
  use Ecto.Repo,
    otp_app: :on_course,
    adapter: Ecto.Adapters.Postgres
end
