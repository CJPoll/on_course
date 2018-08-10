defmodule OnCourse.QuizzesTest do
  use OnCourse.DataCase

  @test_module OnCourse.Quizzes

  alias OnCourse.{Accounts, Courses}
  alias OnCourse.Accounts.User
  alias OnCourse.Courses.{Course, Topic}
  alias OnCourse.Quizzes.{Category, CategoryItem}

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
    category_item_params = %{name: "CategoryItem I"}

    {:ok, %Category{} = category} =
      @test_module.add_category(topic, %{name: "Category II"})

    state =
      %{
        category: category,
        category_params: category_params,
        category_item_params: category_item_params,
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
      assert {:ok, %Category{name: ^name}} =
        @test_module.add_category(topic, params)
    end

    test "sets the correct topic", %{topic: topic, category_params: params} do
      assert {:ok, %Category{topic: ^topic}} =
        @test_module.add_category(topic, params)
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

    test "requires the name to be unique within a topic", %{category_params: params, topic: topic} do
      assert {:ok, %Category{}} = @test_module.add_category(topic, params)
      assert {:error, cs} = @test_module.add_category(topic, params)
      assert {:name, "has already been taken"} in Ectoplasm.errors_on(cs)
    end
  end

  describe "add_category_item/2" do
    test "has a valid setup", %{category: category, category_item_params: params} do
      assert {:ok, %CategoryItem{}} =
        @test_module.add_category_item(category, params)
    end

    test "sets the correct name for the category", %{category: category, category_item_params: %{name: name} = params} do
      assert {:ok, %CategoryItem{name: ^name}} =
        @test_module.add_category_item(category, params)
    end

    test "sets the correct topic", %{category: category, category_item_params: params} do
      assert {:ok, %CategoryItem{category: ^category}} =
        @test_module.add_category_item(category, params)
    end

    test "requires the name to be present", %{category: category, category_item_params: params} do
      {:error, cs} = @test_module.add_category_item(category, params |> Map.delete(:name))
      assert {:name, "can't be blank"} in Ectoplasm.errors_on(cs)
    end

    test "requires the category to be present", %{category_item_params: params} do
      assert_raise FunctionClauseError, fn ->
        @test_module.add_category_item(nil, params)
      end
    end
  end
end
