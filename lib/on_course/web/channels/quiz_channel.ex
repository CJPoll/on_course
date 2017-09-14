defmodule OnCourse.Web.QuizChannel do
  use OnCourse.Web, :channel
  alias OnCourse.Quiz.Session.Worker, as: SessionWorker

  require Logger

  def join("quiz:" <> quiz_id, payload, socket) do
    IO.inspect("Joining Quiz: #{quiz_id}")
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (quiz:lobby).
  def handle_in("current_question", _payload, socket) do
    Logger.debug "Said hello!"
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
