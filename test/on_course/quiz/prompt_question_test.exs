defmodule OnCourse.Quizzes.PromptQuestion.Test do
  use OnCourse.DataCase

  @test_module OnCourse.Quizzes.PromptQuestion
  @repo_module OnCourse.Repo

  setup do
    state =
      %{
        valid_params: %{
          prompt: "What shape is the earth?",
          correct_answer: "Spherical"
        }
      }
    {:ok, state}
  end

  valid_params!()

  describe "fields" do
    required(:prompt)
    required(:correct_answer)
  end
end
