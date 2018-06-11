defmodule OnCourse.Repo.Migrations.CreateOnCourse.Accounts.User do
  use Ecto.Migration

  def change do
    create table(:accounts_users) do
      add :email, :string, null: false
      add :avatar, :string
      add :handle, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:accounts_users, [:email])
  end
end
