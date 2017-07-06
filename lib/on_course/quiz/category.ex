defmodule OnCourse.Quiz.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias OnCourse.Quiz.Category
  alias OnCourse.Courses.Topic

  @type params :: %{
    name: String.t
  }

  schema "quiz_categories" do
    field :name, :string

    belongs_to :topic, OnCourse.Courses.Topic

    timestamps()
  end

  @doc false
  def changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> foreign_key_constraint(:topic_id)
  end

  @doc false
  @spec topic(Ecto.Changeset.t, Topic.t) :: Ecto.Changeset.t
  def topic(%Ecto.Changeset{} = cs, %Topic{} = topic) do
    put_assoc(cs, :topic, topic)
  end
end
