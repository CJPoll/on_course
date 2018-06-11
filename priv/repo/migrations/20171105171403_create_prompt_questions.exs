defmodule OnCourse.Repo.Migrations.CreatePromptQuestions do
  use Ecto.Migration

  def change do
    create table(:quiz_prompt_questions) do
      add :prompt, :string, null: false
      add :correct_answer, :string, null: false

      add :topic_id, references(:courses_topics, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:quiz_prompt_questions, [:prompt])
    create unique_index(:quiz_prompt_questions, [:topic_id, :prompt])
  end
end
