defmodule OnCourse.Courses do
  @moduledoc """
  The boundary for the Courses system.
  """

  import Ecto.Query, warn: false
  alias OnCourse.Repo

  alias OnCourse.Courses.Course
  alias OnCourse.Accounts.User

  @spec new_course(User.t, Course.params)
  :: {:ok, Course.t}
  | {:error, Ecto.Changeset.t}
  def new_course(%User{} = owner, course_params) do
    %Course{}
    |> Course.changeset(course_params)
    |> Course.owner(owner)
    |> Repo.insert
  end
end
