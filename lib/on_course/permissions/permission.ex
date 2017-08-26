defmodule OnCourse.Permission do
  alias OnCourse.Accounts.User
  alias OnCourse.Courses.{Course, Topic}
  alias OnCourse.Quiz
  alias OnCourse.Quiz.Category
  alias OnCourse.Quiz.{Category, CategoryItem}
  alias OnCourse.Repo

  import Ecto.Query, only: [from: 2]

  @type action :: :view | :create | :modify | :delete | :quiz
  @type resource ::
    Course.t
    | {Course.t, Topic}
    | Topic.t
    | {Topic.t, Quiz}
    | {Topic.t, Category}

  @spec can?(User.t, action, resource) :: boolean
  def can?(%User{} = user, :view, %Course{id: course_id}) do
    user =
      user
      |> Repo.preload(:courses)
      |> Repo.preload(:enrolled_courses)

    course_ids = Enum.map(user.courses, &(&1.id))
    enrolled_course_ids = Enum.map(user.enrolled_courses, &(&1.id))

    course_id in course_ids || course_id in enrolled_course_ids
  end

  def can?(%User{} = user, :create, {%Course{id: id}, Topic}) do
    user = if Ecto.assoc_loaded?(user.courses), do: user, else: Repo.preload(user, :courses)

    course_ids = Enum.map(user.courses, &(&1.id))

    id in course_ids
  end

  def can?(%User{} = user, :create, {%Topic{id: id}, Category}) do
    q =
      from u in User,
        inner_join: c in Course, on: c.owner_id == u.id,
        inner_join: t in Topic, on: t.course_id == c.id,
        where: t.id == ^id,
        where: u.id == ^user.id,
        select: t.id

    if Repo.one(q), do: true, else: false
  end

  def can?(%User{id: user_id}, :view, %Topic{id: topic_id}) do
    q1 =
      from u in User,
        inner_join: c in Course, on: c.owner_id == u.id,
        inner_join: t in Topic, on: t.course_id == c.id,
        where: t.id == ^topic_id,
        where: u.id == ^user_id,
        select: t.id

    q2 =
      from u in User,
        inner_join: e in "courses_enrollments", on: e.user_id == u.id,
        inner_join: c in Course, on: e.course_id == c.id,
        inner_join: t in Topic, on: t.course_id == c.id,
        where: t.id == ^topic_id,
        where: u.id == ^user_id,
        select: t.id

    if Repo.one(q2) || Repo.one(q1) , do: true, else: false
  end

  def can?(%User{id: user_id}, :modify, {%Topic{id: topic_id}, Quiz}) do
    q =
      from u in User,
        inner_join: c in Course, on: c.owner_id == u.id,
        inner_join: t in Topic, on: t.course_id == c.id,
        where: t.id == ^topic_id,
        where: u.id == ^user_id,
        select: t.id

    if Repo.one(q), do: true, else: false
  end

  def can?(%User{id: user_id}, :delete, %Category{id: category_id}) do
    q =
      from u in User,
        inner_join: c in Course, on: c.owner_id == u.id,
        inner_join: t in Topic, on: t.course_id == c.id,
        inner_join: cat in Category, on: cat.topic_id == t.id,
        where: cat.id == ^category_id,
        where: u.id == ^user_id,
        select: cat.id

    if Repo.one(q), do: true, else: false
  end

  def can?(%User{id: user_id}, :view, %Category{id: category_id}) do
    q =
      from u in User,
        inner_join: c in Course, on: c.owner_id == u.id,
        inner_join: t in Topic, on: t.course_id == c.id,
        inner_join: cat in Category, on: cat.topic_id == t.id,
        where: cat.id == ^category_id,
        where: u.id == ^user_id,
        select: cat.id

    if Repo.one(q) , do: true, else: false
  end

  def can?(%User{id: user_id}, :view, {%Category{id: category_id}, CategoryItem}) do
    q =
      from u in User,
        inner_join: c in Course, on: c.owner_id == u.id,
        inner_join: t in Topic, on: t.course_id == c.id,
        inner_join: cat in Category, on: cat.topic_id == t.id,
        where: cat.id == ^category_id,
        where: u.id == ^user_id,
        select: cat.id

    if Repo.one(q) , do: true, else: false
  end

  def can?(%User{id: user_id}, :create, {%Category{id: category_id}, CategoryItem}) do
    q =
      from u in User,
        inner_join: c in Course, on: c.owner_id == u.id,
        inner_join: t in Topic, on: t.course_id == c.id,
        inner_join: cat in Category, on: cat.topic_id == t.id,
        where: cat.id == ^category_id,
        where: u.id == ^user_id,
        select: cat.id

    if Repo.one(q) , do: true, else: false
  end

  def can?(%User{} = user, :quiz, %Topic{} = topic) do
    owns?(user, topic) || enrolled_in?(user, topic)
  end

  @spec enrolled_in?(User.t, Topic.t) :: boolean
  defp enrolled_in?(%User{id: user_id}, %Topic{id: topic_id}) do
    q =
      from u in User,
        inner_join: e in "courses_enrollments", on: e.user_id == u.id,
        inner_join: c in Course, on: e.course_id == c.id,
        inner_join: t in Topic, on: t.course_id == c.id,
        where: t.id == ^topic_id,
        where: u.id == ^user_id,
        select: t.id
    if Repo.one(q), do: true, else: false
  end

  @spec owns?(User.t, Topic.t) :: boolean
  defp owns?(%User{id: user_id}, %Topic{id: topic_id}) do
    q =
      from u in User,
        inner_join: c in Course, on: c.owner_id == u.id,
        inner_join: t in Topic, on: t.course_id == c.id,
        where: t.id == ^topic_id,
        where: u.id == ^user_id,
        select: t.id

    if Repo.one(q), do: true, else: false
  end
end
