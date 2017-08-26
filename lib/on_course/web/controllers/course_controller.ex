defmodule OnCourse.Web.Course.Controller do
  use OnCourse.Web, :controller

  alias OnCourse.Courses
  alias OnCourse.Courses.Course

  plug Guardian.Plug.EnsureResource

  plug :scrub_params, "course" when action in [:create]

  def create(%Plug.Conn{} = conn, %{"course" => course_params}) do
    case Courses.new_course(conn.assigns.current_user, course_params) do
      {:ok, %Course{} = course} ->
        render(conn, "show.html", course: Repo.preload(course, :topics))
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
    course =
      course_id
      |> Courses.find
      |> Repo.preload(:topics)

    cond do
      course == nil ->
        render(conn, ErrorView, "404.html", [])
      Permission.can?(current_user, :view, course) ->
        render(conn, "show.html", course: course)
      true ->
        render(conn, ErrorView, "403.html", [])
    end
  end
end
