defmodule OnCourse.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias OnCourse.Accounts.User

  @required [:email, :avatar]
  @type id :: String.t | pos_integer

  schema "accounts_users" do
    field :avatar, :string
    field :email, :string
    field :handle, :string

    has_many :courses, OnCourse.Courses.Course, foreign_key: :owner_id
    many_to_many :enrolled_courses, OnCourse.Courses.Course, join_through: "courses_enrollments"

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :avatar, :handle])
    |> validate_required(@required)
    |> unique_constraint(:email)
  end
end
