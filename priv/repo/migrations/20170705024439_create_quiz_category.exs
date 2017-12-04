defmodule OnCourse.Repo.Migrations.CreateOnCourse.Quiz.Category do
  use Ecto.Migration

  def change do
    create table(:quiz_categories) do
      add :name, :string, null: false
      add :topic_id, references(:courses_topics, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:quiz_categories, [:topic_id])
    create unique_index(:quiz_categories, [:topic_id, :name])
  end
end
