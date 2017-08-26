defmodule OnCourse.Plugs.CurrentUser do
  import Plug.Conn

  def init([]) do
    {:ok, {}}
  end

  def call(%Plug.Conn{} = conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    assign(conn, :current_user, current_user)
  end
end
