defmodule OnCourse.Courses.Course.Test do
  use OnCourse.DataCase
  use Ectoplasm

  @test_module OnCourse.Courses.Course

  setup do
    valid_params =
      %{
        name: "Some Name"
      }

    {:ok, %{valid_params: valid_params}}
  end

  validate_params!()

  required_field(:name)
end
