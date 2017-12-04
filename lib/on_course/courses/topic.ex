defmodule OnCourse.Courses.Topic do
  use OnCourse.Model

  alias OnCourse.Courses.{Course, Module}
  alias OnCourse.Quiz.Category

  @type params :: %{
    :name => String.t,
    :module_id => id
  }

  schema "courses_topics" do
    field :name, :string

    belongs_to :course, Course
    belongs_to :module, Module
    has_many :categories, OnCourse.Quiz.Category
    has_many :prompt_questions, OnCourse.Quiz.PromptQuestion

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
end
