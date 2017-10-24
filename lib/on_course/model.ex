defmodule OnCourse.Model do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias OnCourse.Model

      @type id :: Model.id
    end
  end

  @type association(t) :: %Ecto.Association.NotLoaded{} | t
  @type id :: pos_integer
end
