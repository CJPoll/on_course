defmodule OnCourse.Permission do
  alias OnCourse.Accounts.User
  alias OnCourse.Courses.Course
  alias OnCourse.Repo

  @type action :: :view
  @type resource :: Course.t | Course.id

  @spec can?(User.t, action, resource) :: boolean
  def can?(%User{} = user, :view, %Course{id: course_id}) do
    user =
      user
      |> Repo.preload(:courses)
      |> Repo.preload(:enrolled_courses)

    course_ids = Enum.map(user.courses, &(&1.id))
    enrolled_course_ids = Enum.map(user.enrolled_courses, &(&1.id))

    course_id in course_ids || course_id in enrolled_course_ids
  end
end
