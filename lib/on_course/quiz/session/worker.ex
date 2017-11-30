defmodule OnCourse.Quiz.Session.Worker do
  use GenStateMachine, handle_event_function: true, state_enter: false

  require Logger

  alias OnCourse.Accounts.User
  alias OnCourse.Courses.Topic
  alias OnCourse.Quiz.{Question, Session}

  defstruct [:pid]
  @type t :: %__MODULE__{}

  defmodule Data do
    defstruct [:session]
    @type t :: %__MODULE__{
      session: Session.t
    }
  end

  @initial_state :asking

  # Client Functions

  @spec start_link(User.t, Topic.t)
  :: GenServer.on_start
  def start_link(%User{} = user, %Topic{} = topic) do
    Logger.debug("#{__MODULE__}.start_link/2")
    session = Session.new(user, topic)
    GenStateMachine.start_link(__MODULE__, {session}, name: {:global, session.id})
  end

  def state(%__MODULE__{pid: pid}) do
    GenStateMachine.call(pid, :state)
  end

  @spec stop(t) :: :ok
  def stop(%__MODULE__{pid: pid}) do
    GenStateMachine.stop(pid)
  end

  @spec authorized_user?(t, User.t) :: boolean
  def authorized_user?(%__MODULE__{pid: pid}, %User{} = user) do
    GenStateMachine.call(pid, {:authorized_user?, user})
  end

  @spec id_token(t) :: Session.id | nil
  def id_token(%__MODULE__{pid: pid}) do
    GenStateMachine.call(pid, :id_token)
  end

  @spec find_session(Session.id) :: nil | t
  def find_session(quiz_id) do
    case :global.whereis_name(quiz_id) do
      :undefined -> nil
      pid when is_pid(pid) -> %__MODULE__{pid: pid}
    end
  end

  @spec next_question(t) :: :ok
  def next_question(%__MODULE__{pid: pid}) do
    GenStateMachine.cast(pid, :next_question)
  end

  @spec peek(t) :: Question.t | nil
  def peek(%__MODULE__{pid: pid}) when is_pid(pid) do
    GenStateMachine.call(pid, :peek)
  end

  @spec answer(t, [Question.answer]) :: Session.response
  def answer(%__MODULE__{pid: pid}, answers) when is_pid(pid) do
    GenStateMachine.call(pid, {:answer, answers})
  end

  @spec display(t) :: {:asking, Question.t} | {:reviewing, Question.t, Question.answer}
  def display(%__MODULE__{pid: pid}) do
    GenStateMachine.call(pid, :display)
  end

  # Callback Functions

  def init({%Session{} = session}) do
    {:ok, @initial_state, %Data{session: session}}
  end

  defstate :asking do
    defhandler {:call, from}, {:authorized_user?, %User{} = user}, %Data{session: %Session{} = session} = data do
      answer = Session.authorized_user?(session, user)
      {:next_state, current_state, data, [reply_action(from, answer)]}
    end

    defhandler {:call, from}, :id_token, %Data{session: %Session{} = session} = data do
      id_token = Session.identifier(session)
      {:next_state, current_state, data, [reply_action(from, id_token)]}
    end

    defhandler {:call, from}, :peek, %Data{session: %Session{} = session} = data do
      current_question = Session.peek(session)
      {:next_state, current_state, data, [reply_action(from, current_question)]}
    end

    defhandler {:call, from}, :display, %Data{session: %Session{} = session} = data do
      current_question = Session.peek(session)
      reply = {:asking, current_question}
      {:next_state, current_state, data, [reply_action(from, reply)]}
    end

    defhandler {:call, from}, {:answer, answers}, %Data{session: %Session{} = session} = data do
      {_, session} = Session.answer(session, answers)
      [{q, _} | _] = session.answered_questions
      reply = {q, session.last_answer}
      {:next_state, :reviewing, %Data{data | session: session}, [reply_action(from, reply)]}
    end

    defhandler :cast, :next_question, data do
      Logger.debug("#{__MODULE__}.next_question #{inspect current_state}")
      {:next_state, current_state, data}
    end
  end

  defstate :reviewing do
    defhandler {:call, from}, {:authorized_user?, %User{} = user}, %Data{session: %Session{} = session} = data do
      answer = Session.authorized_user?(session, user)
      {:next_state, current_state, data, [reply_action(from, answer)]}
    end

    defhandler {:call, from}, :display, %Data{session: %Session{} = session} = data do
      [{q, _} | _] = session.answered_questions
      reply = {:reviewing, q, session.last_answer}
      {:next_state, current_state, data, [reply_action(from, reply)]}
    end

    defhandler {:call, from}, :peek, %Data{session: %Session{} = session} = data do
      [{current_question, _} | _] = session.answered_questions
      {:next_state, current_state, data, [reply_action(from, current_question)]}
    end

    defhandler {:call, from}, {:answer, _answers}, %Data{session: %Session{} = session} = data do
      [{q, _} | _] = session.answered_questions
      reply = {q, session.last_answer}
      {:next_state, :reviewing, data, [reply_action(from, reply)]}
    end

    defhandler :cast, :next_question, data do
      Logger.debug("#{__MODULE__}.next_question #{inspect current_state}")
      case data.session.questions do
        [] ->
          Logger.debug("Stopping - no questions")
          {:stop, :normal}
        _ ->
          Logger.debug("Next state asking")
          {:next_state, :asking, data}
      end
    end
  end

  def handle_event({:call, from}, :state, current_state, %Data{} = data) do
    {:next_state, current_state, data, [reply_action(from, data)]}
  end

  def terminate(reason, state, _data) do
    Logger.info("Terminating session: #{inspect reason} in state: #{inspect state}")
  end
end
