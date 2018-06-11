defmodule OnCourse.Repo.Migrations.CreateOnCourse.Quiz.CategoryItem do
  use Ecto.Migration

  def change do
    create table(:category_items) do
      add :name, :string, null: false
      add :category_id, references(:quiz_categories, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:category_items, [:category_id])
    create unique_index(:category_items, [:category_id, :name])
  end
end
