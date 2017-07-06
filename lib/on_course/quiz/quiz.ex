defmodule OnCourse.Quiz do
  @moduledoc """
  The boundary for the Quiz system.
  """

  import Ecto.Query, warn: false
  alias OnCourse.Repo

  alias OnCourse.Quiz.Category
  alias OnCourse.Courses.Topic

  @doc """
  Adds a category to a given topic. The topic struct is a required parameter,
  raising a FunctionClauseException if not present.
  """
  @spec add_category(Topic.t, Category.params)
  :: {:ok, Category.t}
  | {:error, Ecto.Changeset.t}
  def add_category(%Topic{} = topic, params) do
    %Category{}
    |> Category.changeset(params)
    |> Category.topic(topic)
    |> Repo.insert
  end
end
