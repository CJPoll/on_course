defmodule OnCourse.Quiz do
  @moduledoc """
  The boundary for the Quiz system.
  """

  import Ecto.Query, warn: false
  alias OnCourse.Repo

  alias OnCourse.Quiz.{Category, CategoryItem, Question, Session}
  alias OnCourse.Quiz.Session.Worker, as: SessionWorker
  alias OnCourse.Quiz.Session.Supervisor, as: SessionSupervisor
  alias OnCourse.Courses.Topic
  alias OnCourse.Accounts.User

  @doc """
  Adds a category to a given topic. The topic struct is a required parameter,
  raising a FunctionClauseException if not present.
  """
  @spec add_category(Topic.t, Category.params)
  :: {:ok, Category.t}
  | {:error, Ecto.Changeset.t}
  def add_category(%Topic{} = topic, params) do
    %Category{}
    |> Category.changeset(params)
    |> Category.topic(topic)
    |> Repo.insert
  end

  @spec add_category_item(Category.t, CategoryItem.params)
  :: {:ok, CategoryItem.t}
  | {:error, Ecto.Changeset.t}
  def add_category_item(%Category{} = category, params) do
    %CategoryItem{}
    |> CategoryItem.changeset(params)
    |> CategoryItem.category(category)
    |> Repo.insert
  end

  @spec category(Category.id) :: Category.t | nil
  def category(category_id) do
    Repo.get(Category, category_id)
  end

  @spec delete(Category.t)
  :: {:ok, Category.t}
  | {:error, Ecto.Changeset.t}
  def delete(%Category{} = category) do
    Repo.delete(category)
  end

  @spec id_token(SessionWorker.t) :: Session.id_token | nil
  def id_token(%SessionWorker{} = worker) do
    SessionWorker.id_token(worker)
  end

  @spec with_category_items(Category.t) :: Category.t
  def with_category_items(%Category{} = category) do
    Repo.preload(category, :category_items)
  end

  @spec with_quiz_data(Topic.t | Topic.id) :: Topic.t
  def with_quiz_data(%Topic{id: id}), do: with_quiz_data(id)
  def with_quiz_data(id) when is_binary(id) or is_integer(id) do
    q =
      from t in Topic,
        where: t.id == ^id,
        preload: [:categories, categories: :category_items]

    Repo.one(q)
  end

  @spec with_topic(Category.t) :: Category.t
  def with_topic(%Category{} = category) do
    Repo.preload(category, :topic)
  end

  @doc """
  This function takes a topic and returns a list of questions designed to aid
  in learning the topic.

  All categories and associated category_items must be loaded onto the topic;
  this function does no interaction with the database - it only generates
  questions from the loaded data.
  """
  @spec questions(Topic.t) :: [Question.t]
  def questions(%Topic{} = topic) do
    category_names =
      topic.categories
      |> Enum.map(fn(cat) -> cat.name end)
      |> MapSet.new

    item_names =
      topic.categories
      |> Enum.reduce([], fn(category, items) ->
           category.category_items ++ items
         end)
      |> Enum.map(fn(cat_item) -> cat_item.name end)
      |> MapSet.new

    join = cross_join(category_names, item_names)

    category_index =
      topic.categories
      |> Enum.map(fn(%Category{} = category) ->
           {category.name, Enum.map(category.category_items, &(&1.name))}
         end)
      |> Map.new()

    item_index =
      Enum.reduce(topic.categories, %{}, fn(category, index) ->
        Enum.reduce(category.category_items, index, fn(item, i) ->
          Map.update(i, item.name, [category.name], fn(categories) -> [category.name | categories] end )
        end)
      end)

    Enum.map(join, fn(e) ->
      if :rand.uniform(2) - 1 == 0 do
        Question.multiple_choice(e, item_index, category_index)
      else
        Question.true_false(e, item_index)
      end
    end)
  end

  @spec start_quiz(User.t, Topic.t)
  :: {:ok, SessionWorker.t}
  | {:error, :ignore}
  | {:error, term}
  def start_quiz(%User{} = user, %Topic{} = topic) do
    SessionSupervisor.start_session(user, topic)
  end

  @type a :: term
  @type b :: term

  @spec cross_join(MapSet.t(a), MapSet.t(b)) :: MapSet.t({a, b})
  def cross_join(as, bs) do
    list = for a <- as, b <- bs, do: {a, b}
    MapSet.new(list)
  end
end
