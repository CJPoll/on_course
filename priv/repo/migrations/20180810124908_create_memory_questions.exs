defmodule OnCourse.Repo.Migrations.CreateMemoryQuestions do
  use Ecto.Migration

  def change do
    create table(:quiz_memory_questions) do
      add :prompt, :string, null: false

      add :topic_id, references(:courses_topics, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:quiz_memory_questions, [:prompt])
    create unique_index(:quiz_memory_questions, [:topic_id, :prompt])

    create table(:quiz_memory_answers) do
      add :text, :string, null: false

      add :memory_question_id, references(:quiz_memory_questions, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
