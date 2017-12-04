defmodule Mix.Tasks.Crs.MvTopic do
  use Mix.Task

  alias OnCourse.Courses.{Module, Topic}
  alias OnCourse.Repo

  @shortdoc "Reassigns a topic to another module"
  def run([topic_id, new_module_id]) do
    Application.ensure_all_started(:on_course)

    topic = ensure_find(Topic, topic_id)
    module = ensure_find(Module, new_module_id)

    if topic.course_id == module.course_id do
      res =
        topic
        |> Topic.changeset(%{module_id: module.id})
        |> Repo.update

      case res do
        {:ok, _} -> :ok
        {:error, cs} ->
          errs = Ectoplasm.errors_on(cs)
          IO.inspect("Could not move topic: #{inspect errs}")
      end
    else
      IO.inspect("Cannot move topic to module ##{new_module_id} - not in the same course")
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
