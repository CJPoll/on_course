defmodule OnCourse.Web.LandingController do
  use OnCourse.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
