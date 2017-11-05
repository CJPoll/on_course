defmodule OnCourse.Quiz.NewSession do
  use GenStateMachine, state_functions: true, state_enter: true

  @initial_state :open

  defmodule Data do
    defstruct []
  end

  def start do
    GenStateMachine.start(__MODULE__, [], [])
  end

  def init(_) do
    {:ok, @initial_state, %Data{}}
  end

  defstate :closed do
    defhandler :info, _msg, %Data{} = data do
      IO.inspect(current_state)
      {:next_state, :open, data}
    end
  end
end
