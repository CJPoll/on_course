defmodule OnCourse.Quiz.Session.Worker.Test do
  use ExUnit.Case, async: false

  alias OnCourse.Accounts.User
  alias OnCourse.Courses.Topic
  alias OnCourse.Quiz.{Category, CategoryItem, PromptQuestion}

  @test_module OnCourse.Quiz.Session.Worker

  describe "start_link/2" do
    setup do
      user = %User{id: 1}
      topic = %Topic{
        id: 1,
        categories: [
          %Category{
            name: "category",
            category_items: [
              %CategoryItem{name: "category_item"}
            ]}],
        prompt_questions: [%PromptQuestion{prompt: "What is 2+2?", correct_answer: "4"}]}

      state =
        %{
          user: user,
          topic: topic
        }
      {:ok, state}
    end

    test "globally registers the quiz under the session id", context do
      @test_module.start_link(context.user, context.topic)
    end
  end
end
