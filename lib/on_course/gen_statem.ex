defmodule GenStateMachine do
  defmacro __using__(_) do
    quote do
      @behaviour :gen_statem
      import GenStateMachine
    end
  end
enter_loop
  @type t :: :gen_statem.server_ref

  @type from :: :gen_statem.from
  @type message :: term
  @type reply :: term
  @type reply_action :: {reply, from, reply}
  @type start_option :: {:name, GenServer.name} | :gen_statem.start_opt
  @type time_out :: timeout
  | {clean_timeout, timeout()}
  | {dirty_timeout, timeout()}

  @spec start_link(module, term, [start_option])
  :: {:ok, pid}
  | :ignore
  | {:error, term}
  def start_link(module, args, opts \\ []) do
    name = Keyword.get(opts, :name, nil)

    case name do
      nil ->
        :gen_statem.start_link(module, args, opts)
      name ->
        :gen_statem.start_link(name, module, args, Keyword.delete(opts, :name))
    end
  end

  @spec call(t, message) :: reply
  def call(state_machine, message) do
    :gen_statem.call(state_machine, message)
  end

  @spec call(t, message, time_out) :: reply
  def call(state_machine, message, timeout) do
    :gen_statem.call(state_machine, timeout)
  end

  @spec cast(t, message) :: :ok
  def cast(state_machine, message) do
    :gen_statem.cast(state_machine, message)
  end

  @spec reply([reply_action] | reply_action) :: :ok
  def reply(reply) do
    :gen_statem.reply(reply)
  end

  @spec reply(from, reply)
  def reply(from, reply) do
    :gen_statem.reply(from, reply)
  end
end
