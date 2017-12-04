defmodule OnCourse.Courses.Test do
  use OnCourse.DataCase

  alias OnCourse.Accounts.User
  alias OnCourse.Courses.{Course, Topic}

  @test_module OnCourse.Courses

  doctest @test_module

  setup do
    course_params = %{name: "My Course"}
    topic_params = %{name: "Topic I"}
    owner = %User{
      avatar: "http://example.com",
      email: "email@example.com",
      handle: "ExampleHandle"
    } |> Repo.insert!

    {:ok, %Course{} = course} = @test_module.new_course(owner, %{name: "Course II"})

    state =
      %{
        course: course,
        course_params: course_params,
        user: owner,
        topic_params: topic_params
      }

    {:ok, state}
  end

  describe "new_course/2" do
    test "setup is valid", %{course_params: params, user: owner} do
      assert {:ok, %Course{}} = @test_module.new_course(owner, params)
    end

    test "requires the owner to be present", %{course_params: params} do
      assert_raise FunctionClauseError, fn ->
        @test_module.new_course(nil, params)
      end
    end

    test "requires a name", %{course_params: params, user: owner} do
      {:error, cs} = @test_module.new_course(owner, params |> Map.delete(:name))
      assert {:name, "can't be blank"} in Ectoplasm.errors_on(cs)
    end

    test "Sets the owner to the provided owner", %{course_params: params, user: owner} do
      owner_id = owner.id
      assert {:ok, %Course{owner_id: ^owner_id}} = @test_module.new_course(owner, params)
    end
  end

  describe "add_topic/2" do
    test "setup is valid", %{course: course, topic_params: params} do
      assert {:ok, _} = @test_module.add_topic(course, params)
    end

    test "requires the course to be present", %{topic_params: params} do
      assert_raise FunctionClauseError, fn ->
        @test_module.new_course(nil, params)
      end
    end

    test "requires a name", %{course: course, topic_params: params} do
      {:error, cs} = @test_module.add_topic(course, params |> Map.delete(:name))
      assert {:name, "can't be blank"} in Ectoplasm.errors_on(cs)
    end

    test "Sets the course to the provided course", %{course: course, topic_params: params} do
      course_id = course.id
      assert {:ok, %Topic{course_id: ^course_id}} = @test_module.add_topic(course, params)
    end
  end
end
