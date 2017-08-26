defmodule OnCourse.Quiz.Session.Worker do
  use GenServer

  alias OnCourse.Accounts.User
  alias OnCourse.Courses.Topic
  alias OnCourse.Quiz.Session

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

  @spec id_token(t) :: Session.id_token | nil
  def id_token(%__MODULE__{pid: pid}) do
    GenServer.call(pid, :id_token)
  end

  # Callback Functions

  def init({%Session{} = session}) do
    {:ok, %State{session: session}}
  end

  def handle_call(:id_token, _from, %State{session: %Session{} = session} = state) do
    id_token = Session.identifier(session)
    {:reply, id_token, state}
  end

  def handle_call(_, _, state) do
    {:reply, :unknown_message, state}
  end

  def handle_info(:timeout, state) do
    {:stop, :timeout, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
