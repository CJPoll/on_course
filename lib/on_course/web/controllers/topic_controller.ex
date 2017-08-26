defmodule OnCourse.Web.Topic.Controller do
  use OnCourse.Web, :controller

  alias OnCourse.Courses
  alias OnCourse.Courses.Topic
  alias OnCourse.Permission

  plug Guardian.Plug.EnsureAuthenticated, handler: OnCourse.Web.AuthErrorHandler

  plug :scrub_params, "topic" when action in [:create]
  plug :scrub_params, "topic_id" when action in [:show, :update]
  plug :scrub_params, "course_id" when action in [:create, :create, :new]

  def create(%Plug.Conn{} = conn, %{"course_id" => course_id, "topic" => topic_params}) do
    course = Courses.find(course_id)

    cond do
      course == nil ->
        render(conn, ErrorView, "404.html", [])
      Permission.can?(conn.assigns.current_user, :create, {course, Topic}) ->
        case Courses.add_topic(course, topic_params) do
          {:ok, %Topic{} = topic} ->
            render(conn, "show.html", topic: topic)
          {:error, cs} ->
            render(conn, "new.html", changeset: cs)
        end
      true->
        render(conn, ErrorView, "403.html", [])
    end
  end

  def new(%Plug.Conn{} = conn, %{"course_id" => course_id}) do
    course = Courses.find(course_id)

    if Permission.can?(conn.assigns.current_user, :create, {course, Topic}) do
      cs = Courses.changeset_for(%Topic{}, %{})

      conn
      |> assign(:course, course)
      |> render("new.html", changeset: cs)
    else
      render(conn, ErrorView, "403.html", [])
    end
  end

  def show(%Plug.Conn{} = conn, %{"topic_id" => topic_id}) do
    topic =
      topic_id
      |> Courses.topic
      |> Repo.preload(:categories)

    cond do
      topic == nil ->
        render(conn, ErrorView, "404.html", [])

      Permission.can?(conn.assigns.current_user, :view, topic) ->
        render(conn, "show.html", topic: topic)

      true ->
        render(conn, ErrorView, "403.html", [])
    end
  end
end
