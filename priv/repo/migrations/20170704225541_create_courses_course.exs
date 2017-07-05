defmodule OnCourse.Repo.Migrations.CreateOnCourse.Courses.Course do
  use Ecto.Migration

  def change do
    create table(:courses_courses) do
      add :name, :string
      add :owner_id, references(:accounts_users, on_delete: :delete_all)

      timestamps()
    end

    create index(:courses_courses, [:owner_id])
  end
end
