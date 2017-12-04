defmodule OnCourse.Web.Course.Controller do
  use OnCourse.Web, :controller

  alias OnCourse.Courses
  alias OnCourse.Courses.{Course, Module, Topic}

  plug Guardian.Plug.EnsureResource

  plug :scrub_params, "course" when action in [:create]

  def create(%Plug.Conn{} = conn, %{"course" => course_params}) do
    case Courses.new_course(conn.assigns.current_user, course_params) do
      {:ok, %Course{} = course} ->
        conn
        |> put_flash(:success, "Course Created!")
        |> redirect(to: Path.course_path(Endpoint, :show, course))
      {:error, cs} ->
        conn
        |> put_flash(:error, "Creating course failed: #{inspect Ectoplasm.errors_on(cs)}")
        |> redirect(to: Path.courses_path(Endpoint, :index))
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

    course_changeset = Courses.changeset_for(%Course{}, %{})

    render(conn, "index.html", courses: user.courses, enrolled_courses: user.enrolled_courses, course_changeset: course_changeset)
  end

  def new(%Plug.Conn{} = conn, _params) do
    cs = Courses.changeset_for(%Course{}, %{})

    render(conn, "new.html", changeset: cs)
  end

  def show(%Plug.Conn{} = conn, %{"course_id" => course_id}) do
    current_user = Guardian.Plug.current_resource(conn)

    course =
      Course
      |> Course.with_id(course_id)
      |> Course.with_topics
      |> Course.with_modules
      |> Repo.one

    cond do
      course == nil ->
        render(conn, ErrorView, "404.html", [])
      Permission.can?(current_user, :view, course) ->
        topics = Courses.topics_by_module(course.topics)
        render(conn, "show.html",
               course: course,
               topics: topics,
               module_changeset: Courses.changeset_for(%Module{}, %{}),
               topic_changeset: Courses.changeset_for(%Topic{}, %{}))
      true ->
        render(conn, ErrorView, "403.html", [])
    end
  end

  def create_module(%Plug.Conn{} = conn, %{"course_id" => course_id, "module" => module_params}) do
    current_user = Guardian.Plug.current_resource(conn)

    course =
      Course
      |> Course.with_id(course_id)
      |> Course.with_topics
      |> Repo.one

    cond do
      course == nil ->
        render(conn, ErrorView, "404.html", [])
      Permission.can?(current_user, :create, {course, Module}) ->
        case Courses.add_module(course, module_params) do
          {:ok, %Module{}} ->
            conn
            |> put_flash(:success, "Module Created!")
            |> redirect(to: Path.course_path(Endpoint, :show, course))
          {:error, cs} ->
            conn
            |> put_flash(:error, "Creating module failed: #{inspect Ectoplasm.errors_on(cs)}")
            |> redirect(to: Path.course_path(Endpoint, :show, course))
        end
      true ->
        render(conn, ErrorView, "403.html", [])
    end
  end
end
