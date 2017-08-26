defmodule OnCourse.Quiz.Session.Supervisor do
  use Supervisor
  alias OnCourse.Accounts.User
  alias OnCourse.Courses.Topic

  alias OnCourse.Quiz.Session
  alias OnCourse.Quiz.Session.Worker

  @child Worker
  @type child :: Worker.t

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: Session.Supervisor)
  end

  def init(_) do
    child_spec = [worker(@child, [])]
    opts = [strategy: :simple_one_for_one]

    supervise(child_spec, opts)
  end

  @spec start_session(User.t, Topic.t)
  :: {:ok, @child.t}
  | {:error, :ignore}
  | {:error, term}
  def start_session(%User{} = user, %Topic{} = topic) do
    case Supervisor.start_child(Session.Supervisor, [user, topic]) do
      {:ok, pid} ->
        {:ok, %@child{pid: pid}}

      {:ok, pid, _info} ->
        {:ok, %@child{pid: pid}}

      :already_present ->
        {:error, :already_present}

      {:error, {:already_started, pid}} ->
        {:ok, %@child{pid: pid}}

      {:error, _reason} = err -> err
    end
  end
end
