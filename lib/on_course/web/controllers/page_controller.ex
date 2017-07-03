defmodule OnCourse.Web.PageController do
  use OnCourse.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def dashboard(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render conn, "dashboard.html", user: user
  end

  def unauthenticated(conn, _params) do
    redirect(conn, to: landing_path(Endpoint, :index))
  end
end
