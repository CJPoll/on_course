defmodule OnCourse.Web.Quizzes.Controller do
  use OnCourse.Web, :controller

  require Logger

  alias OnCourse.Quizzes
  alias OnCourse.Quizzes.Session.Worker, as: SessionWorker
  alias OnCourse.Courses.Topic

  plug Guardian.Plug.EnsureResource

  plug :scrub_params, "topic_id" when action == :quiz_question

  def next_question(conn, %{"topic_id" => topic_id}) do
    quiz_data(conn, topic_id, fn(conn, _topic, session) ->
      Quizzes.next_question(session)
      redirect(conn, to: "/topics/#{topic_id}/quiz")
    end)
  end

  def quiz(%Plug.Conn{} = conn, %{"topic_id" => topic_id, "responses" => responses}) do
    Logger.debug("#{__MODULE__}.")
    quiz_data(conn, topic_id, fn(conn, topic, session) ->
      {question, responses} = Quizzes.answer(session, responses)
      render(conn, "answer_question.html", topic: topic, question: question, responses: responses)
    end)
  end

  def quiz(%Plug.Conn{} = conn, %{"topic_id" => topic_id}) do
    quiz_data(conn, topic_id, fn(conn, topic, session) ->
      case Quizzes.display(session) do
        {:asking, question} ->
          render(conn, "quiz.html", topic: topic, question: question, responses: [])
        {:reviewing, question, responses} ->
          render(conn, "answer_question.html", topic: topic, question: question, responses: responses)
      end
    end)
  end

  @type response :: String.t
  @type callback :: ((Plug.Conn.t, Topic.id, [response]) -> Plug.Conn.t)

  @spec quiz_data(Plug.Conn.t, Topic.id, callback) :: Plug.Conn.t
  defp quiz_data(%Plug.Conn{} = conn, topic_id, callback) do
    topic = Quizzes.with_quiz_data(topic_id)

    cond do
      topic == nil ->
        render(conn, ErrorView, "404.html", [])
      Permission.can?(conn.assigns.current_user, :quiz, topic) ->
        session =
          conn.assigns.current_user
          |> Quizzes.id_token(topic)
          |> Quizzes.find_session

        quiz =
          case session do
            nil ->
              Logger.debug("============== Starting Session ===============")
              {:ok, session_worker} = OnCourse.Quizzes.start_quiz(conn.assigns.current_user, topic)
              session_worker
            %SessionWorker{} = session_worker->
              session_worker
          end

        callback.(conn, topic, quiz)
      true ->
        render(conn, ErrorView, "403.html", [])
    end
  end
end
