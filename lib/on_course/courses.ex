defmodule OnCourse.Courses do
  @moduledoc """
  The boundary for the Courses system.
  """

  alias OnCourse.Accounts.User
  alias OnCourse.Courses.{Course, Module, Topic}
  alias OnCourse.{Permission, Repo}

  @spec add_topic(User.t, Course.t | Course.id, Topic.params)
  :: {:ok, Topic.t}
  | {:error, Ecto.Changeset.t}
  def add_topic(%User{} = user, %Course{} = course, params) do
    if Permission.can?(user, :create, {course, Topic}) do
      %Topic{}
      |> Topic.changeset(params)
      |> Topic.course(course)
      |> Repo.insert
    else
      {:error, :unauthorized}
    end
  end

  def add_topic(%User{} = user, course_id, params) do
    case __MODULE__.find(course_id) do
      nil -> {:error, :course_not_found}
      %Course{} = course -> add_topic(user, course, params)
    end
  end

  @spec add_module(Course.t, Module.params)
  :: {:ok, Topic.t}
  | {:error, Ecto.Changeset.t}
  def add_module(%Course{} = course, params) do
    %Module{}
    |> Module.changeset(params)
    |> Module.course(course)
    |> Repo.insert
  end

  @spec changeset_for(Course.t | Course.empty | Topic.t, %{}) :: Ecto.Changeset.t
  def changeset_for(%Course{} = course, params) do
    Course.changeset(course, params)
  end

  def changeset_for(%Topic{} = topic, params) do
    Topic.changeset(topic, params)
  end

  def changeset_for(%Module{} = module, params) do
    Module.changeset(module, params)
  end

  @spec enrolled(User.t | User.id) :: [Course.t]
  def enrolled(%User{} = user) do
    enrolled(user.id)
  end

  def enrolled(user_id) when is_binary(user_id) or is_integer(user_id) do
    Course
    |> Course.enrolled(user_id)
    |> Repo.all
  end

  @spec find(Course.id) :: Course.t | nil
  def find(course_id) do
    Repo.get(Course, course_id)
  end

  @spec owned_by(User.t | User.id) :: [Course.t]
  def owned_by(%User{} = user) do
    owned_by(user.id)
  end

  def owned_by(user_id) when is_binary(user_id) or is_integer(user_id) do
    Course
    |> Course.owned_by(user_id)
    |> Repo.all
  end

  @spec preload_categories(Topic.t) :: Topic.t
  def preload_categories(%Topic{} = topic) do
    Repo.preload(topic, :categories)
  end

  @spec topic(Topic.id) :: Topic.t | nil
  def topic(topic_id) do
    Repo.get(Topic, topic_id)
  end

  @spec new_course(User.t, Course.params)
  :: {:ok, Course.t}
  | {:error, Ecto.Changeset.t}
  def new_course(%User{} = owner, course_params) do
    %Course{}
    |> Course.changeset(course_params)
    |> Course.owner(owner)
    |> Repo.insert
  end

  @spec topics_by_module([Topic.t]) :: %{Module.name => Topic.t}
  @doc """
  Given a list of topics, returns the topics grouped by module name

  iex> OnCourse.Courses.topics_by_module([ %OnCourse.Courses.Topic{name: "topic1", module: %OnCourse.Courses.Module{name: "module1"}}, %OnCourse.Courses.Topic{name: "topic2", module: %OnCourse.Courses.Module{name: "module1"}}, %OnCourse.Courses.Topic{name: "topic3", module: %OnCourse.Courses.Module{name: "module1"}}, %OnCourse.Courses.Topic{name: "topic4", module: %OnCourse.Courses.Module{name: "module2"}}, %OnCourse.Courses.Topic{name: "topic5", module: %OnCourse.Courses.Module{name: "module2"}} ])
  %{
    "module1" => [
      %OnCourse.Courses.Topic{name: "topic1", module: %OnCourse.Courses.Module{name: "module1"}},
      %OnCourse.Courses.Topic{name: "topic2", module: %OnCourse.Courses.Module{name: "module1"}},
      %OnCourse.Courses.Topic{name: "topic3", module: %OnCourse.Courses.Module{name: "module1"}}
    ],
    "module2" => [
      %OnCourse.Courses.Topic{name: "topic4", module: %OnCourse.Courses.Module{name: "module2"}},
      %OnCourse.Courses.Topic{name: "topic5", module: %OnCourse.Courses.Module{name: "module2"}}
    ]
  }
  """
  def topics_by_module(topics) when is_list(topics) do
    Enum.group_by(topics, fn
      (%Topic{module: nil}) ->
        "Default"
      (%Topic{module: %Module{name: name}}) ->
        name
      (%Topic{module: %Ecto.Association.NotLoaded{}}) ->
        raise "#{__MODULE__}.topics_by_module/1 requires the module to be preloaded onto all topics."
    end)
  end
end
