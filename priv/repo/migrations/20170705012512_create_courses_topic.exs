defmodule OnCourse.Repo.Migrations.CreateOnCourse.Courses.Topic do
  use Ecto.Migration

  def change do
    create table(:courses_topics) do
      add :name, :string, null: false
      add :course_id, references(:courses_courses, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:courses_topics, [:course_id])
    create unique_index(:courses_topics, [:course_id, :name])
  end
end
