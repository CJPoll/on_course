defmodule OnCourse.Web.AuthErrorHandler do
  use OnCourse.Web, :controller

  def unauthenticated(%Plug.Conn{} = conn, _params) do
    redirect(conn, to: "/")
  end
end
