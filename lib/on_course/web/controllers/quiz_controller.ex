defmodule OnCourse.Web.Quiz.Controller do
  use OnCourse.Web, :controller

  require Logger

  alias OnCourse.Quiz
  alias OnCourse.Quiz.Session.Worker, as: SessionWorker
  alias OnCourse.Courses.Topic

  plug Guardian.Plug.EnsureResource

  plug :scrub_params, "topic_id" when action == :quiz_question

  def quiz_question(%Plug.Conn{} = conn, %{"topic_id" => topic_id}) do
    quiz_data(conn, topic_id, [], fn(conn, topic, question, _responses, _options) ->
      render(conn, "quiz.html", topic: topic, question: question, responses: [])
    end)
  end

  def quiz_question(%Plug.Conn{} = conn, %{"topic_id" => topic_id, "responses" => responses}) do
    quiz_data(conn, topic_id, responses, fn(conn, topic, question, responses, options) ->
      render(conn, "answer_question.html", topic: topic, question: question, responses: responses, options: options)
    end)
  end

  @type response :: String.t
  @type callback :: ((Plug.Conn.t, Topic.id, [response]) -> Plug.Conn.t)

  @spec quiz_data(Plug.Conn.t, Topic.id, [response], callback) :: Plug.Conn.t
  defp quiz_data(%Plug.Conn{} = conn, topic_id, responses, callback) do
    topic = Quiz.with_quiz_data(topic_id)

    cond do
      topic == nil ->
        render(conn, ErrorView, "404.html", [])
      Permission.can?(conn.assigns.current_user, :quiz, topic) ->
        session =
          conn.assigns.current_user
          |> Quiz.id_token(topic)
          |> Quiz.find_session

        quiz =
          case session do
            nil ->
              {:ok, session_worker} = OnCourse.Quiz.start_quiz(conn.assigns.current_user, topic)
              session_worker
            %SessionWorker{} = session_worker->
              session_worker
          end

        question = Quiz.current_question(quiz)
        options = Quiz.options(question)

        callback.(conn, topic, question, responses, options)
      true ->
        render(conn, ErrorView, "403.html", [])
    end
  end
end
