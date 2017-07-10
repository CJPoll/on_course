defmodule OnCourse.Web.Router do
  use OnCourse.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Ueberauth
  end

  pipeline :authenticated_browser do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OnCourse.Web do
    pipe_through [:browser, :authenticated_browser] # Use the default browser stack

    get "/", LandingController, :index
    get "/dashboard", PageController, :dashboard
    get "/courses", Course.Controller, :enrolled, as: :enrolled_courses
    get "/courses/new", Course.Controller, :new, as: :new_course
    get "/courses/:course_id", Course.Controller, :show, as: :course
    post "/admin/courses", Course.Controller, :create, as: :courses
    post "/courses/:course_id/enrollments", Course.Controller, :enroll, as: :enroll
  end

  scope "/auth", OnCourse.Web do
    pipe_through :browser # Use the default browser stack

    get "/:provider", Auth.Controller, :request
    get "/:provider/callback", Auth.Controller, :callback
  end
end
