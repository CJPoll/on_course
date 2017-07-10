defmodule OnCourse.Repo.Migrations.CreateOnCourse.Quiz.CategoryItem do
  use Ecto.Migration

  def change do
    create table(:category_items) do
      add :name, :string, null: false
      add :category_id, references(:quiz_categories, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:category_items, [:category_id])
    create unique_index(:category_items, [:category_id, :name])
  end
end
