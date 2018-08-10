defmodule OnCourse.Quizzes.PromptQuestion do
  use OnCourse.Model

  alias OnCourse.Courses.Topic

  @type params :: %{:prompt => String.t, :correct_answer => String.t}

  @optional_fields [:topic_id]
  @required_fields [:prompt, :correct_answer]

  schema "quiz_prompt_questions" do
    field :prompt, :string
    field :correct_answer, :string

    belongs_to :topic, OnCourse.Courses.Topic

    timestamps()
  end

  def changeset(data \\ %__MODULE__{}, params) do
    data
    |> cast(params, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:prompt, name: :quiz_prompt_questions_topic_id_prompt_index)
    |> foreign_key_constraint(:topic)
    |> cast_assoc(:topic)
  end

  @spec topic(Ecto.Changeset.t, Topic.t) :: Ecto.Changeset.t
  def topic(%Ecto.Changeset{} = cs, %Topic{} = topic) do
    put_assoc(cs, :topic, topic)
  end

  @spec with_topic(Ecto.Queryable.t) :: Ecto.Queryable.t
  def with_topic(query) do
    from pq in query,
      inner_join: t in Topic, on: pq.topic_id == t.id,
      preload: [topic: t]
  end

  @spec with_id(Ecto.Queryable.t, id) :: Ecto.Queryable.t
  def with_id(query, id) do
    from pq in query,
      where: pq.id == ^id
  end
end
