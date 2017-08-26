defmodule OnCourse.Web.Quiz.Controller do
  use OnCourse.Web, :controller
  alias OnCourse.{Courses, Quiz}

  plug Guardian.Plug.EnsureResource

  plug :scrub_params, "topic_id" when action == :take_quiz

  def take_quiz(%Plug.Conn{} = conn, %{"topic_id" => topic_id}) do
    topic =
      topic_id
      |> Courses.topic
      |> Quiz.with_quiz_data

    cond do
      topic == nil ->
        render(conn, ErrorView, "404.html", [])
      Permission.can?(conn.assigns.current_user, :quiz, topic) ->
        {:ok, quiz} = OnCourse.Quiz.start_quiz(conn.assigns.current_user, topic)

        id_token = OnCourse.Quiz.id_token(quiz)

        render(conn, "quiz.html", topic: topic, id_token: id_token)
      true ->
        render(conn, ErrorView, "403.html", [])
    end
  end
end
