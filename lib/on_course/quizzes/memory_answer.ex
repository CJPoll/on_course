defmodule OnCourse.Quizzes.MemoryAnswer do
  use OnCourse.Model

  alias OnCourse.Quizzes.MemoryQuestion

  @type text :: String.t

  @type params :: %{
    text: text,
    memory_question_id: MemoryQuestion.id
  }

  schema "quiz_memory_answers" do
    field :text, :string

    belongs_to :memory_question, MemoryQuestion

    timestamps()
  end

  @type t :: %__MODULE__{
    text: String.t,
    memory_question: Model.association(MemoryQuestion.t)
  }

  @doc false
  def changeset(%__MODULE__{} = memory_answer, attrs) do
    memory_answer
    |> cast(attrs, [:text])
    |> validate_required([:text])
    |> foreign_key_constraint(:memory_question)
    |> unique_constraint(:name, name: :memory_answers_memory_question_id_name_index)
  end

  @doc false
  def memory_question(%Ecto.Changeset{} = cs, %MemoryQuestion{} = memory_question) do
    put_assoc(cs, :memory_question, memory_question)
  end
end
