defmodule OnCourse.Courses.Module do
  use OnCourse.Model

  alias OnCourse.Courses.{Course, Topic}

  @type name :: String.t

  schema "courses_modules" do
    field :name, :string
    belongs_to :course, Course
    has_many :topics, Topic

    timestamps()
  end

  @type t :: %__MODULE__{
    course: Model.association(Course.t),
    course_id: id,
    inserted_at: DateTime.t,
    name: name,
    topics: Model.association([Topic.t]),
    updated_at: DateTime.t,
  }

  @doc false
  def changeset(%__MODULE__{} = module, attrs) do
    module
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @spec course(Ecto.Changeset.t, Course.t) :: Ecto.Changeset.t
  def course(cs, %Course{} = course) do
    put_assoc(cs, :course, course)
  end
end
