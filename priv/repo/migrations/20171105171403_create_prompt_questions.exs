defmodule OnCourse.Repo.Migrations.CreatePromptQuestions do
  use Ecto.Migration

  def change do
    create table(:quiz_prompt_questions) do
      add :prompt, :string
      add :correct_answer, :string

      add :topic_id, references(:course_topics)

      timestamps()
    end

    create index(:quiz_prompt_questions, [:prompt])
    create unique_index(:quiz_prompt_questions, [:topic_id, :prompt])
  end
end
