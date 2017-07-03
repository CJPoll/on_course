defmodule OnCourse.Repo.Migrations.CreateOnCourse.Accounts.User do
  use Ecto.Migration

  def change do
    create table(:accounts_users) do
      add :email, :string
      add :avatar, :string
      add :handle, :string

      timestamps()
    end

    create unique_index(:accounts_users, [:email])
  end
end
