defmodule OnCourse.Web.MemoryQuestion.Controller do
  use OnCourse.Web, :controller

  plug Guardian.Plug.EnsureResource

  alias OnCourse.{Courses, Quizzes}
  alias OnCourse.Quizzes.MemoryQuestion
  alias OnCourse.Web.Router.Helpers, as: Path

  def create(%Plug.Conn{} = conn, %{"memory_question" => %{"answer" => answers} = question, "topic_id" => _topic_id} = params) do
    answers =
      answers
      |> Enum.sort(fn({i, _}, {j, _}) ->
        i < j
      end)
      |> Enum.map(fn({_, value}) -> %{"text" => value} end)

    question =
      question
      |> Map.delete("answer")
      |> Map.put_new("memory_answers", answers)
      |> IO.inspect

    params = Map.update(params, "memory_question", question, fn(_) -> question end)

    create(conn, params)
  end

  def create(%Plug.Conn{} = conn, %{"memory_question" => params, "topic_id" => topic_id}) do
    topic = Courses.topic(topic_id)

    if Permission.can?(conn.assigns.current_user, :create, {topic, OnCourse.Quizzes.MemoryQuestion}) do
      case Quizzes.add_memory_question(topic, params) do
        {:ok, %MemoryQuestion{}} ->
          conn
          |> put_flash(:success, "Memory Question created!")
          |> redirect(to: Path.topic_path(Endpoint, :show, topic.id))
        {:error, cs} ->
          conn
          |> put_flash(:error, "Creating memory question failed: #{inspect cs}")
          |> redirect(to: Path.topic_path(Endpoint, :show, topic.id))
      end
    end
  end

  def delete(%Plug.Conn{} = conn, %{"memory_question_id" => mq_id}) do
    pq =
      MemoryQuestion
      |> MemoryQuestion.with_id(mq_id)
      |> MemoryQuestion.with_topic
      |> Repo.one

    cond do
      pq == nil ->
        render(conn, ErrorView, "404.html", [])

      Permission.can?(conn.assigns.current_user, :delete, {pq.topic, MemoryQuestion}) ->
        case Quizzes.delete(pq) do
          {:ok, %MemoryQuestion{}} ->
            conn
            |> put_flash(:success, "Memory Question deleted!")
            |> redirect(to: Path.topic_path(Endpoint, :show, pq.topic.id))
          {:error, cs} ->
            conn
            |> put_flash(:error, "Couldn't delete memory question: #{inspect Ectoplasm.errors_on(cs)}")
            |> redirect(to: Path.topic_path(Endpoint, :show, pq.topic.id))
        end

      true ->
        render(conn, ErrorView, "403.html", [])
    end
  end
end
