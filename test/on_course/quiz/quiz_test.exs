defmodule OnCourse.QuizTest do
  use OnCourse.DataCase

  @test_module OnCourse.Quiz

  alias OnCourse.{Accounts, Courses}
  alias OnCourse.Accounts.User
  alias OnCourse.Courses.{Course, Topic}
  alias OnCourse.Quiz.Category

  setup do
    {:ok, %User{} = owner} =
      Accounts.upsert_user(%User{}, %{
        email: "email@example.com",
        handle: "ahandle",
        avatar: "http://example.com/avatar"
      })

    {:ok, %Course{} = course} =
      Courses.new_course(owner, %{name: "Course I"})

    {:ok, %Topic{} = topic} =
      Courses.add_topic(course, %{name: "Topic I"})

    category_params = %{name: "Category I"}

    state =
      %{
        category_params: category_params,
        course: course,
        owner: owner,
        topic: topic
      }

    {:ok, state}
  end

  describe "add_category/2" do
    test "has a valid setup", %{topic: topic, category_params: params} do
      assert {:ok, %Category{}} = @test_module.add_category(topic, params)
    end

    test "sets the correct name for the category", %{topic: topic, category_params: %{name: name} = params} do
      assert {:ok, %Category{name: ^name}} = @test_module.add_category(topic, params)
    end

    test "sets the correct topic", %{topic: topic, category_params: params} do
      assert {:ok, %Category{topic: ^topic}} = @test_module.add_category(topic, params)
    end

    test "requires the name to be present", %{topic: topic, category_params: params} do
      {:error, cs} = @test_module.add_category(topic, params |> Map.delete(:name))
      assert {:name, "can't be blank"} in Ectoplasm.errors_on(cs)
    end

    test "requires the topic to be present", %{category_params: params} do
      assert_raise FunctionClauseError, fn ->
        @test_module.add_category(nil, params)
      end
    end
  end
end
