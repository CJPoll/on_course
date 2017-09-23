defmodule OnCourse.Quiz.Session.Worker do
  use GenServer

  require Logger

  alias OnCourse.Accounts.User
  alias OnCourse.Courses.Topic
  alias OnCourse.Quiz.{Question, Session}

  defstruct [:pid]
  @type t :: %__MODULE__{}

  defmodule State do
    defstruct [:session]
    @type t :: %__MODULE__{
      session: Session.t
    }
  end

  # Client Functions

  @spec start_link(User.t, Topic.t)
  :: GenServer.on_start
  def start_link(%User{} = user, %Topic{} = topic) do
    session = Session.new(user, topic)
    GenServer.start_link(__MODULE__, {session}, name: {:global, session.id})
  end

  @spec authorized_user?(t, User.t) :: boolean
  def authorized_user?(%__MODULE__{pid: pid}, %User{} = user) do
    GenServer.call(pid, {:authorized_user?, user})
  end

  @spec id_token(t) :: Session.id | nil
  def id_token(%__MODULE__{pid: pid}) do
    GenServer.call(pid, :id_token)
  end

  @spec find_session(Session.id) :: nil | t
  def find_session(quiz_id) do
    case :global.whereis_name(quiz_id) do
      :undefined -> nil
      pid when is_pid(pid) -> %__MODULE__{pid: pid}
    end
  end

  @spec peek(t) :: Question.t | nil
  def peek(%__MODULE__{pid: pid}) when is_pid(pid) do
    GenServer.call(pid, :peek)
  end

  # Callback Functions

  def init({%Session{} = session}) do
    {:ok, %State{session: session}}
  end

  def handle_call(:id_token, _from, %State{session: %Session{} = session} = state) do
    id_token = Session.identifier(session)
    {:reply, id_token, state}
  end

  def handle_call(:peek, _from, %State{session: %Session{} = session} = state) do
    current_question = Session.peek(session)
    {:reply, current_question, state}
  end

  def handle_call({:authorized_user?, user}, _from, %State{session: %Session{} = session} = state) do
    authorized = Session.authorized_user?(session, user)
    {:reply, authorized, state}
  end

  def handle_call(msg, _, state) do
    Logger.error("#{__MODULE__} received message it didn't understand: #{inspect msg}")
    {:reply, :unknown_message, state}
  end

  def handle_info(:timeout, state) do
    {:stop, :timeout, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
