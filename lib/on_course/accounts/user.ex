defmodule OnCourse.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias OnCourse.Accounts.User

  @required [:email, :avatar]

  schema "accounts_users" do
    field :avatar, :string
    field :email, :string
    field :handle, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :avatar, :handle])
    |> validate_required(@required)
    |> unique_constraint(:email)
  end
end
