defmodule OnCourse.Quiz.Question.Test do
  use ExUnit.Case

  @test_module OnCourse.Quiz.Question

  describe "true_false/2" do
    test "returns a question" do
      assert %@test_module{} =
        @test_module.true_false({"category", "anitem"}, %{"anitem" => ["category"]})
    end

    test "returns a true-false question" do
      assert %@test_module{question_type: :true_false} =
        @test_module.true_false({"category", "anitem"}, %{"anitem" => ["category"]})
    end

    test "returns the correct answer as a list" do
      %@test_module{correct_answer: answers} =
        @test_module.true_false({"category", "anitem"}, %{"anitem" => ["category"]})

      assert is_list(answers)
    end

    test "returns the correct answer as string" do
      %@test_module{correct_answer: [answer]} =
        @test_module.true_false({"category", "anitem"}, %{"anitem" => ["category"]})

      assert is_binary(answer)
    end

    test "returns the correct answer as true if item is in category" do
      assert %@test_module{correct_answer: ["true"]} =
        @test_module.true_false({"category", "anitem"}, %{"anitem" => ["category"]})
    end

    test "returns the correct answer as false if item is not in category" do
      assert %@test_module{correct_answer: ["false"]} =
        @test_module.true_false({"category", "anitem"}, %{"anitem" => ["category2"]})
    end

    test "returns prompt as a string" do
      %@test_module{prompt: prompt} =
        @test_module.true_false({"category", "anitem"}, %{"anitem" => ["category2"]})

      assert is_binary(prompt)
    end
  end

  describe "multiple_choice/3" do
    test "returns a question" do
      assert %@test_module{} =
        @test_module.multiple_choice({"category", "item"}, %{"item" => ["category"]}, %{"category" => ["item"]})
    end

    test "returns a multiple_choice question" do
      assert %@test_module{question_type: {:multiple_choice, _}} =
        @test_module.multiple_choice({"category", "item"}, %{"item" => ["category"]}, %{"category" => ["item"]})
    end

    test "returns a list of options" do
      assert %@test_module{question_type: {_, options}} =
        @test_module.multiple_choice({"category", "item"}, %{"item" => ["category"]}, %{"category" => ["item"]})

      assert is_list(options)
    end

    test "returns a prompt as a string" do
      %@test_module{prompt: prompt} =
        @test_module.multiple_choice({"category", "item"}, %{"item" => ["category"]}, %{"category" => ["item"]})

      assert is_binary(prompt)
    end
  end
end
