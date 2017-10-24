defmodule OnCourse.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias OnCourse.Accounts.User
  alias OnCourse.Courses.Course

  @required [:email, :avatar]
  @type id :: String.t | pos_integer

  schema "accounts_users" do
    field :avatar, :string
    field :email, :string
    field :handle, :string

    has_many :courses, Course, foreign_key: :owner_id
    many_to_many :enrolled_courses, Course, join_through: "courses_enrollments"

    timestamps()
  end

  @type t :: %__MODULE__{
    avatar: String.t,
    email: String.t,
    handle: String.t,
    courses: [Course.t],
    enrolled_courses: [Course.t]
  }

  @type empty :: %__MODULE__{}

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :avatar, :handle])
    |> validate_required(@required)
    |> unique_constraint(:email)
  end
end
