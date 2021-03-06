defmodule OnCourse.Courses.Enrollment do
  use Ecto.Schema
  import Ecto.Changeset
  alias OnCourse.Courses.Enrollment


  schema "courses_enrollments" do
    field :course_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Enrollment{} = enrollment, attrs) do
    enrollment
    |> cast(attrs, [])
    |> validate_required([])
    |> foreign_key_constraint(:course_id)
    |> foreign_key_constraint(:user_id)
  end
end
