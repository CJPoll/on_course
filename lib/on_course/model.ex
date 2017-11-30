defmodule OnCourse.Model do
  require Logger
  import Ecto.Changeset
  alias Ecto.Changeset

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias OnCourse.Model
      import OnCourse.Model
      import Ecto.Query

      @type id :: Model.id
    end
  end

  @type association(t) :: %Ecto.Association.NotLoaded{} | t

  @type id :: pos_integer
  def get_field(map, field) when is_atom(field) do
    field_name = field_for(map, field)
    Map.get(map, field_name)
  end

  def field_for(map, field) when is_atom(field) do
    cond do
      Map.has_key?(map, field) -> field
      Map.has_key?(map, s = Atom.to_string(field)) -> s
      true -> nil
    end
  end

  def delete_field(map, field) when is_atom(field) do
    field = field_for(map, field)
    Map.delete(map, field)
  end

  def put_field(map, field, value) when is_atom(field) do
    head =
      map
      |> Map.to_list
      |> List.first

    atom_keys =
      if head do
        head
        |> elem(0)
        |> is_atom
      else
        true
      end

    if atom_keys do
      Map.put(map, field, value)
    else
      Map.put(map, Atom.to_string(field), value)
    end
  end

  def instantiate(%Changeset{valid?: false} = cs) do
    Logger.debug("Invalid Changeset: #{inspect cs}")
    nil
  end

  def instantiate(%Changeset{valid?: true} = cs) do
    apply_changes(cs)
  end

  def value_for(map, field) when is_atom(field) do
    map[field] || map[Atom.to_string(field)]
  end
end
