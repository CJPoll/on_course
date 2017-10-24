defmodule OnCourse.Courses do
  @moduledoc """
  The boundary for the Courses system.
  """

  import Ecto.Query, warn: false
  alias OnCourse.Repo

  alias OnCourse.Courses.{Course, Topic}
  alias OnCourse.Accounts.User

  @spec add_topic(Course.t, Topic.params)
  :: {:ok, Topic.t}
  | {:error, Ecto.Changeset.t}
  def add_topic(%Course{} = course, params) do
    %Topic{}
    |> Topic.changeset(params)
    |> Topic.course(course)
    |> Repo.insert
  end

  @spec changeset_for(Course.t | Course.empty | Topic.t, %{}) :: Ecto.Changeset.t
  def changeset_for(%Course{} = course, params) do
    Course.changeset(course, params)
  end

  def changeset_for(%Topic{} = topic, params) do
    Topic.changeset(topic, params)
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
end
