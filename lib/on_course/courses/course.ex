defmodule OnCourse.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset
  alias OnCourse.Courses.Course
  alias OnCourse.Accounts.User

  @type params :: %{
    name: String.t
  }

  schema "courses_courses" do
    field :name, :string

    belongs_to :owner, OnCourse.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(%Course{} = course, attrs) do
    course
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> foreign_key_constraint(:owner_id)
  end

  @doc false
  @spec owner(Ecto.Changeset.t, User.t) :: Ecto.Changeset.t
  def owner(%Ecto.Changeset{} = cs, %User{} = owner) do
    put_assoc(cs, :owner, owner)
  end
end
