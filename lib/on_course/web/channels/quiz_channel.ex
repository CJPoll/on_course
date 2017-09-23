defmodule OnCourse.Web.QuizChannel do
  use OnCourse.Web, :channel
  alias OnCourse.Quiz.Session.Worker, as: SessionWorker
  alias OnCourse.GuardianSerializer
  alias OnCourse.Accounts.User

  require Logger

  def join("quiz:" <> quiz_id, %{"userId" => user_id}, socket) do
    with {:ok, %{"sub" => token}} <- Guardian.decode_and_verify(user_id),
         {:ok, %User{} = user} <- GuardianSerializer.from_token(token),
         %SessionWorker{} = worker <- SessionWorker.find_session(quiz_id),
         true <- SessionWorker.authorized_user?(worker, user)
    do
      socket =
        socket
        |> assign(:current_user, user)
        |> assign(:quiz_session, worker)

      {:ok, socket}
    else
      err -> {:error, %{reason: err}}
    end
  end

  def join(_, _, _socket) do
    {:error, %{reason: "Invalid Params"}}
  end

  def handle_in("current_question", _payload, socket) do
    if question = SessionWorker.peek(socket.assigns.quiz_session) do
      push socket, "current_question", question
      {:reply, :ok, socket}
    else
      push socket, "current_question", %{}
      {:reply, :ok, socket}
    end
  end

  def handle_info(:ping, socket) do
    {:noreply, socket}
  end
end
