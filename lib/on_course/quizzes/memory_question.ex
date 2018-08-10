defmodule OnCourse.Quizzes.MemoryQuestion do
  use OnCourse.Model

  alias OnCourse.Courses.Topic
  alias OnCourse.Quizzes.MemoryAnswer

  @type params :: %{:prompt => String.t, optional(:memory_answers) => [MemoryAnswer.params]}

  @optional_fields [:topic_id]
  @required_fields [:prompt]

  schema "quiz_memory_questions" do
    field :prompt, :string

    belongs_to :topic, OnCourse.Courses.Topic
    has_many :memory_answers, MemoryAnswer

    timestamps()
  end

  def changeset(data \\ %__MODULE__{}, params) do
    data
    |> cast(params, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:prompt, name: :quiz_memory_questions_topic_id_prompt_index)
    |> foreign_key_constraint(:topic)
    |> cast_assoc(:memory_answers)
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

  @spec with_answers(Ecto.Queryable.t) :: Ecto.Queryable.t
  def with_answers(query) do
    from mq in query,
      inner_join: ma in MemoryAnswer, on: mq.id == ma.memory_question_id,
      preload: [memory_answers: ma]
  end

  @spec with_id(Ecto.Queryable.t, id) :: Ecto.Queryable.t
  def with_id(query, id) do
    from pq in query,
      where: pq.id == ^id
  end
end
