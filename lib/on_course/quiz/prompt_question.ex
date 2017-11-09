defmodule OnCourse.Quiz.PromptQuestion do
  use OnCourse.Model

  alias OnCourse.Courses.Topic

  @type params :: %{:prompt => String.t, :correct_answer => String.t}

  @optional_fields []
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
  end

  @spec topic(Ecto.Changeset.t, Topic.t) :: Ecto.Changeset.t
  def topic(%Ecto.Changeset{} = cs, %Topic{} = topic) do
    put_assoc(cs, :topic, topic)
  end
end
