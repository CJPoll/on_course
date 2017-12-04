defmodule OnCourse.Repo.Migrations.CreateModules do
  use Ecto.Migration

  def change do
    create table(:courses_modules) do
      add :name, :string
      add :course_id, references(:courses_courses, on_delete: :delete_all), null: false

      timestamps()
    end

    alter table(:courses_topics) do
      add :module_id, references(:courses_modules, on_delete: :delete_all), null: false
    end

    create unique_index(:courses_modules, [:course_id, :name])
  end
end
