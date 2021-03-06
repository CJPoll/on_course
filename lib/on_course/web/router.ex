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
    plug OnCourse.Plugs.CurrentUser
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

    get "/courses/:course_id/topics/new", Topic.Controller, :new, as: :new_topic
    post "/courses/:course_id/topics", Topic.Controller, :create, as: :topics
    post "/courses/:course_id/modules", Course.Controller, :create_module, as: :modules

    get "/topics/:topic_id", Topic.Controller, :show, as: :topic
    post "/topics/:topic_id/categories", Category.Controller, :create, as: :categories
    post "/topics/:topic_id/prompt_questions", PromptQuestion.Controller, :create
    post "/topics/:topic_id/memory_questions", MemoryQuestion.Controller, :create
    delete "/prompt_questions/:prompt_question_id", PromptQuestion.Controller, :delete
    delete "/memory_questions/:memory_question_id", MemoryQuestion.Controller, :delete

    get "/topics/:topic_id/quiz", Quizzes.Controller, :quiz, as: :ask_question
    post "/topics/:topic_id/quiz", Quizzes.Controller, :quiz, as: :ask_question
    get "/topics/:topic_id/quiz/next", Quizzes.Controller, :next_question, as: :next_question
    get "/categories/:category_id", Category.Controller, :show, as: :category
    delete "/categories/:category_id", Category.Controller, :delete

    post "/categories/:category_id/category_items", Category.Controller, :create, as: :category_items
  end

  scope "/auth", OnCourse.Web do
    pipe_through :browser # Use the default browser stack

    get "/:provider", Auth.Controller, :request, as: :login
    get "/:provider/callback", Auth.Controller, :callback
  end
end
