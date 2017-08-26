defmodule OnCourse.Quiz.CategoryItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias OnCourse.Quiz.Category

  @type name :: String.t

  @type params :: %{
    name: name
  }

  schema "category_items" do
    field :name, :string

    belongs_to :category, OnCourse.Quiz.Category

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = category_item, attrs) do
    category_item
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> foreign_key_constraint(:category_id)
    |> unique_constraint(:name, name: :category_items_category_id_name_index)
  end

  @doc false
  def category(%Ecto.Changeset{} = cs, %Category{} = category) do
    put_assoc(cs, :category, category)
  end
end
