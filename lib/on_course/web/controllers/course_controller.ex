defmodule OnCourse.Web.Course.Controller do
  use OnCourse.Web, :controller

  alias OnCourse.Courses
  alias OnCourse.Courses.Course

  plug Guardian.Plug.EnsureResource

  plug :scrub_params, "course" when action in [:create]

  def create(%Plug.Conn{} = conn, %{"course" => course_params}) do
    current_user =  Guardian.Plug.current_resource(conn)

    case Courses.new_course(current_user, course_params) do
      {:ok, %Course{} = course} ->
        render(conn, "show.html", course: course)
      {:error, cs} ->
        render(conn, "new.html", changeset: cs)
    end
  end

  def enroll(%Plug.Conn{} = conn, _params) do
    send_resp(conn, 200, "Enrolling...")
  end

  def enrolled(%Plug.Conn{} = conn, _params) do
    user =
      conn
      |> Guardian.Plug.current_resource
      |> Repo.preload(:courses)
      |> Repo.preload(:enrolled_courses)

    render(conn, "index.html", courses: user.courses, enrolled_courses: user.enrolled_courses)
  end

  def new(%Plug.Conn{} = conn, _params) do
    cs = Courses.changeset_for(%Course{}, %{})

    render(conn, "new.html", changeset: cs)
  end

  def show(%Plug.Conn{} = conn, %{"course_id" => course_id}) do
    current_user = Guardian.Plug.current_resource(conn)
    course = Courses.find(course_id)

    cond do
      course == nil ->
        send_resp(conn, 404, "No such course")
      Permission.can?(current_user, :view, course) ->
        render(conn, "show.html", course: course)
      true ->
        send_resp(conn, 403, "Unauthorized")
    end
  end
end
