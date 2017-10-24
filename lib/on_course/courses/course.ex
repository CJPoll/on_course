defmodule OnCourse.Courses.Course do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias OnCourse.Courses.{Course, Topic}
  alias OnCourse.Accounts.User

  @type id :: String.t | pos_integer

  @type params :: %{
    name: String.t
  }

  schema "courses_courses" do
    field :name, :string

    belongs_to :owner, OnCourse.Accounts.User
    many_to_many :enrollments, OnCourse.Accounts.User, join_through: "courses_enrollments"

    has_many :topics, Topic

    timestamps()
  end

  @type t :: %__MODULE__{
    name: String.t,
    owner: User.t,
    enrollments: [User.t],
    topics: [Topic.t]
  }

  @type empty :: %__MODULE__{}

  @doc false
  def changeset(%Course{} = course, attrs) do
    course
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> foreign_key_constraint(:owner_id)
  end

  @spec owned_by(Ecto.Queryable.t, id) :: Ecto.Queryable.t
  def owned_by(queryable, user_id) do
    from c in queryable,
      where: c.owner_id == ^user_id
  end

  @spec enrolled(Ecto.Queryable.t, id) :: Ecto.Queryable.t
  def enrolled(queryable, user_id) do
    from c in queryable,
      where: c.owner_id == ^user_id
  end

  @doc false
  @spec owner(Ecto.Changeset.t, User.t) :: Ecto.Changeset.t
  def owner(%Ecto.Changeset{} = cs, %User{} = owner) do
    put_assoc(cs, :owner, owner)
  end
end
