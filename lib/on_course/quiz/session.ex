defmodule OnCourse.Quiz.Session do
  defstruct [:id, :topic, :user, questions: [], answered_questions: []]

  alias OnCourse.Accounts.User
  alias OnCourse.Courses.Topic
  alias OnCourse.Quiz
  alias OnCourse.Quiz.Question

  @type response :: :correct | {:incorrect, [Question.answer]} | no_return
  @type id :: String.t

  @type t :: %__MODULE__{
    answered_questions: [{Question.t, response}],
    id: id,
    questions: [Question.t],
    topic: Topic.t,
    user: User.t
  }

  @doc """
  Creates a new session. The ID is a hash of the user id and topic id.

  All categories and associated category_items must be loaded onto the topic;
  this function does no interaction with the database - it only generates
  questions from the loaded data.
  """
  @spec new(User.t, Topic.t) :: t
  def new(%User{} = user, %Topic{} = topic) do
    id = identifier(user, topic)
    questions = Quiz.questions(topic)

    %__MODULE__{
      id: id,
      user: user,
      topic: topic,
      questions: questions
    }
  end

  @spec identifier(t) :: id
  def identifier(%__MODULE__{id: identifier}) do
    identifier
  end

  @spec identifier(User.t, Topic.t) :: id
  def identifier(%User{id: user_id}, %Topic{id: topic_id}) do
    data = Integer.to_string(user_id) <> Integer.to_string(topic_id)

    :md5
    |> :crypto.hash(data)
    |> Base.encode16
    |> String.downcase
  end

  @spec authorized_user?(t, User.t) :: boolean
  def authorized_user?(%__MODULE__{user: %User{id: id}}, %User{id: id}), do: true
  def authorized_user?(%__MODULE__{}, _), do: false

  @spec peek(t) :: Question.t | nil
  def peek(%__MODULE__{questions: [next | _]}), do: next
  def peek(%__MODULE__{questions: []}), do: nil

  @spec pop(t) :: {t, Question.t | nil}
  def pop(%__MODULE__{questions: [next | rest]} = session) do
    {%__MODULE__{session | questions: rest}, next}
  end
  def pop(%__MODULE__{questions: []} = session), do: {session, nil}

  @spec answer(t, Question.answer)
  :: {response, t}
  def answer(%__MODULE__{questions: []}, _answer) do
    raise "Quiz Session has no more questions, but received an answer"
  end

  def answer(%__MODULE__{questions: [q | rest]} = session, answer) do
    resp =
      if correct?(q, answer), do: :correct, else: incorrect_response(q.correct_answer)
    {resp, %__MODULE__{ session | questions: rest, answered_questions: [{q, answer} | session.answered_questions]}}
  end

  def correct?(%Question{correct_answer: correct_answer}, answer)
  when is_binary(correct_answer) and is_binary(answer) do
    String.downcase(correct_answer) == String.downcase(answer)
  end

  def correct?(%Question{correct_answer: correct_answer}, answer)
  when is_list(correct_answer) and is_list(answer) do
    MapSet.new(correct_answer) == MapSet.new(answer)
  end

  def correct?(%Question{correct_answer: correct_answer}, answer)
  when is_boolean(correct_answer) and is_boolean(answer) do
    correct_answer == answer
  end

  def correct?(_, _), do: false

  defp incorrect_response(answers) when is_list(answers) do
    {:incorrect, answers}
  end

  defp incorrect_response(answer) do
    incorrect_response([answer])
  end
end
