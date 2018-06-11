defmodule OnCourse.Courses.Topic do
  use OnCourse.Model

  alias OnCourse.Courses.{Course, Module}
  alias OnCourse.Quiz.{Category, CategoryItem, PromptQuestion}

  @type params :: %{
    :name => String.t,
    :module_id => id
  }

  schema "courses_topics" do
    field :name, :string

    belongs_to :course, Course
    belongs_to :module, Module
    has_many :categories, Category
    has_many :prompt_questions, PromptQuestion

    timestamps()
  end

  @type t :: %__MODULE__{
    name: String.t,
    course: Model.association(Course.t),
    categories: Model.association([Category.t])
  }

  @doc false
  def changeset(%__MODULE__{} = topic, attrs) do
    topic
    |> cast(attrs, [:name, :module_id])
    |> validate_required([:name, :module_id])
    |> foreign_key_constraint(:course_id)
    |> foreign_key_constraint(:module_id)
  end

  @doc false
  @spec course(Ecto.Changeset.t, Course.t) :: Ecto.Changeset.t
  def course(%Ecto.Changeset{} = cs, %Course{} = course) do
    put_assoc(cs, :course, course)
  end

  @doc false
  @spec module(Ecto.Changeset.t, Module.t) :: Ecto.Changeset.t
  def module(%Ecto.Changeset{} = cs, %Module{} = module) do
    put_assoc(cs, :module, module)
  end

  @spec with_id(Ecto.Queryable.t, id) :: Ecto.Query.t
  def with_id(q, id) do
    from t in q, where: t.id == ^id
  end

  @spec preload_categories(Ecto.Queryable.t) :: Ecto.Query.t
  def preload_categories(q) do
    from t in q,
      left_join: c in Category, on: c.topic_id == t.id,
      left_join: ci in CategoryItem, on: ci.category_id == c.id,
      preload: [categories: {c, category_items: ci}]
  end

  @spec preload_prompt_questions(Ecto.Queryable.t) :: Ecto.Query.t
  def preload_prompt_questions(q) do
    from t in q,
      left_join: pq in PromptQuestion, on: pq.topic_id == t.id,
      preload: [prompt_questions: pq]
  end
end
