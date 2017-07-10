defmodule OnCourse.Repo.Migrations.CreateOnCourse.Courses.Enrollment do
  use Ecto.Migration

  def change do
    create table(:courses_enrollments) do
      add :course_id, references(:courses_courses, on_delete: :nothing), null: false
      add :user_id, references(:accounts_users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:courses_enrollments, [:course_id])
    create index(:courses_enrollments, [:user_id])
  end
end
