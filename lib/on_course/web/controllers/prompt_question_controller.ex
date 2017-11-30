defmodule OnCourse.Web.PromptQuestion.Controller do
  use OnCourse.Web, :controller

  plug Guardian.Plug.EnsureResource

  alias OnCourse.{Courses, Quiz}
  alias OnCourse.Quiz.PromptQuestion
  alias OnCourse.Web.Router.Helpers, as: Path

  def create(%Plug.Conn{} = conn, %{"prompt_question" => params, "topic_id" => topic_id}) do
    topic = Courses.topic(topic_id)

    if Permission.can?(conn.assigns.current_user, :create, {topic, OnCourse.Quiz.PromptQuestion}) do
      case Quiz.add_prompt_question(topic, params) do
        {:ok, %PromptQuestion{}} ->
          conn
          |> put_flash(:success, "Prompt Question created!")
          |> redirect(to: Path.topic_path(Endpoint, :show, topic.id))
        {:error, cs} ->
          conn
          |> put_flash(:error, "Creating prompt question failed: #{inspect Ectoplasm.errors_on(cs)}")
          |> redirect(to: Path.topic_path(Endpoint, :show, topic.id))
      end
    end
  end

  def delete(%Plug.Conn{} = conn, %{"prompt_question_id" => pq_id}) do
    pq =
      PromptQuestion
      |> PromptQuestion.with_id(pq_id)
      |> PromptQuestion.with_topic
      |> Repo.one

    cond do
      pq == nil ->
        render(conn, ErrorView, "404.html", [])

      Permission.can?(conn.assigns.current_user, :delete, {pq.topic, PromptQuestion}) ->
        case Quiz.delete(pq) do
          {:ok, %PromptQuestion{}} ->
            conn
            |> put_flash(:success, "Category deleted!")
            |> redirect(to: Path.topic_path(Endpoint, :show, pq.topic.id))
          {:error, cs} ->
            conn
            |> put_flash(:error, "Couldn't delete category: #{inspect Ectoplasm.errors_on(cs)}")
            |> redirect(to: Path.topic_path(Endpoint, :show, pq.topic.id))
        end

      true ->
        render(conn, ErrorView, "403.html", [])
    end
  end
end
