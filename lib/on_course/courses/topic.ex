defmodule OnCourse.Courses.Topic do
  use Ecto.Schema
  import Ecto.Changeset
  alias OnCourse.Courses.Course

  @type params :: %{:name => String.t}

  schema "course_topics" do
    field :name, :string

    belongs_to :course, Course
    has_many :categories, OnCourse.Quiz.Category

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = topic, attrs) do
    topic
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> foreign_key_constraint(:course_id)
  end

  @doc false
  @spec course(Ecto.Changeset.t, Course.t) :: Ecto.Changeset.t
  def course(%Ecto.Changeset{} = cs, %Course{} = course) do
    put_assoc(cs, :course, course)
  end
end
