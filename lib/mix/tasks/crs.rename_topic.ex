defmodule Mix.Tasks.Crs.RenameTopic do
  use Mix.Task

  alias OnCourse.Courses.Topic
  alias OnCourse.Repo

  @shortdoc "Reassigns a topic to another module"
  def run([topic_id, new_name]) do
    Application.ensure_all_started(:on_course)

    topic = ensure_find(Topic, topic_id)

    res =
      topic
      |> Topic.changeset(%{name: new_name})
      |> Repo.update

    case res do
      {:ok, _} -> :ok
      {:error, cs} ->
        errs = Ectoplasm.errors_on(cs)
        IO.inspect("Could not rename topic: #{inspect errs}")
    end
  end

  defp ensure_find(type, id) do
    entity = Repo.get(type, id)
    if entity == nil do
      raise "Could not find #{type} ##{id}"
    end
    entity
  end
end

