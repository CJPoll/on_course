defmodule GenStateMachine do
  defmodule InvalidConfigException do
    defexception [:message]
  end

  defmacro __using__(config) when is_list(config) do
    state_functions = Keyword.get(config, :state_functions, nil)
    handle_event_function = Keyword.get(config, :handle_event_function, nil)
    state_enter = Keyword.get(config, :state_enter, nil)

    unless state_functions || handle_event_function do
      raise InvalidConfigException, "Must configure either state functions or handle_event functions"
    end

    if state_functions && handle_event_function do
      raise InvalidConfigException, "Can't configure both state functions and handle_event functions"
    end

    []
    |> add_field(:state_functions, state_functions)
    |> add_field(:handle_event_function, handle_event_function)
    |> add_field(:state_enter, state_enter)
    |> do_using(__CALLER__.module)
  end

  def do_using(callback_mode, calling_module) do
    Module.put_attribute(calling_module, :callback_mode, callback_mode)

    quote do
      @behaviour :gen_statem
      import GenStateMachine

      def callback_mode do
        unquote(callback_mode)
      end
    end
  end

  defmacro defstate(state, [do: handlers]) do
    Macro.prewalk(handlers, fn
      ({:current_state, _meta, _}) ->
        state
      ({:defhandler, _meta, [event_type, msg, data, [do: block]]}) ->
        case state_functions?(__CALLER__.module) do
          true ->
            quote do
              def unquote(state)(unquote(event_type), unquote(msg), unquote(data)) do
                unquote(block)
              end
            end
          false ->
            quote do
              def handle_event(unquote(event_type), unquote(msg) = msg, unquote(state) = current_state, unquote(data)) do
                IO.inspect current_state
                IO.inspect msg
                unquote(block)
              end
            end
        end
      (other) ->
        other
    end)
  end

  defp add_field(kw, field, value) do
    if value do
      [field | kw]
    else
      kw
    end
  end

  @type t :: :gen_statem.server_ref

  @type from :: :gen_statem.from
  @type message :: term
  @type reply :: term
  @type reply_action :: {reply, from, reply}
  @type start_option :: {:name, GenServer.name} | :gen_statem.start_opt
  @type time_out :: timeout
  | {:clean_timeout, timeout()}
  | {:dirty_timeout, timeout()}

  @spec start(module, term, [start_option]) :: :gen_statem.start_ret
  def start(module, args, opts) do
    name = Keyword.get(opts, :name, nil)

    case name do
      nil ->
        :gen_statem.start_link(module, args, opts)
      name ->
        :gen_statem.start_link(name, module, args, Keyword.delete(opts, :name))
    end
  end

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

  @spec stop(t) :: :ok
  def stop(ref) do
    :gen_statem.stop(ref)
  end

  @spec call(t, message) :: reply
  def call(state_machine, message) do
    :gen_statem.call(state_machine, message)
  end

  @spec call(t, message, time_out) :: reply
  def call(state_machine, message, timeout) do
    :gen_statem.call(state_machine, message, timeout)
  end

  @spec cast(t, message) :: :ok
  def cast(state_machine, message) do
    :gen_statem.cast(state_machine, message)
  end

  @spec reply([reply_action] | reply_action) :: :ok
  def reply(reply) do
    :gen_statem.reply(reply)
  end

  @spec reply(from, reply) :: :ok
  def reply(from, reply) do
    :gen_statem.reply(from, reply)
  end

  @spec reply_action(from, term) :: {:reply, from, term}
  def reply_action(from, message) do
    {:reply, from, message}
  end

  def state_functions?(module) do
    :state_functions in Module.get_attribute(module, :callback_mode)
  end
end
