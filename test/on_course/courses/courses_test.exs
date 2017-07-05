defmodule OnCourse.Courses.Test do
  use OnCourse.DataCase

  alias OnCourse.Accounts.User
  alias OnCourse.Courses.Course

  @test_module OnCourse.Courses

  setup do
    course_params = %{name: "My Course"}
    owner = %User{
      avatar: "http://example.com",
      email: "email@example.com",
      handle: "ExampleHandle"
    } |> Repo.insert!

    state =
      %{
        course_params: course_params,
        owner: owner
      }

    {:ok, state}
  end

  describe "new_course/2" do
    test "setup is valid", %{course_params: params, owner: owner} do
      assert {:ok, %Course{}} = @test_module.new_course(owner, params)
    end

    test "requires the owner to be present", %{course_params: params} do
      assert_raise FunctionClauseError, fn ->
        @test_module.new_course(nil, params)
      end
    end

    test "requires a name", %{course_params: params, owner: owner} do
      {:error, cs} = @test_module.new_course(owner, params |> Map.delete(:name))
      assert {:name, "can't be blank"} in Ectoplasm.errors_on(cs)
    end

    test "Sets the owner to the provided owner", %{course_params: params, owner: owner} do
      owner_id = owner.id
      assert {:ok, %Course{owner_id: ^owner_id}} = @test_module.new_course(owner, params)
    end
  end
end
