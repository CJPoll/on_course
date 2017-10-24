defmodule OnCourse.Quiz.Session.Test do
  use ExUnit.Case

  alias OnCourse.Accounts.User
  alias OnCourse.Courses.Topic
  alias OnCourse.Quiz.{Category, CategoryItem, Question}

  @test_module OnCourse.Quiz.Session

  @user %User{id: 1}
  @topic %Topic{
    id: 1,
    name: "Social Skills",
    categories: [
      %Category{
        name: "cool",
        category_items: [
          %CategoryItem{name: "Sunglasses"},
          %CategoryItem{name: "Skateboards"},
        ]
      },
      %Category{
        name: "uncool",
        category_items: [
          %CategoryItem{name: "Cargo Shorts"},
          %CategoryItem{name: "Crocs"},
        ]
      }
    ]
  }

  describe "new/2" do
    test "returns a session" do
      assert %@test_module{} = @test_module.new(@user, @topic)
    end
  end

  describe "peek/1" do
    setup :make_session

    test "returns the next question in the list (if there is one)", %{session: %@test_module{questions: [q | _]} = session} do
      assert %Question{} = @test_module.peek(session)
      assert ^q = @test_module.peek(session)
    end

    test "returns nil if the list is empty", %{session: session} do
      assert nil == @test_module.peek(%@test_module{session | questions: []})
    end
  end

  describe "pop/1" do
    setup :make_session

    test "returns the next question in the list (if there is one)", %{session: %@test_module{questions: [q | _]} = session} do
      assert {_, %Question{} = question} = @test_module.pop(session)
      assert question == q
    end

    test "returns the modified session", %{session: %@test_module{questions: [q | rest]} = session} do
      assert {%@test_module{questions: ^rest}, ^q} = @test_module.pop(session)
    end

    test "returns nil if the list is empty", %{session: session} do
      assert {_, nil} = @test_module.pop(%@test_module{session | questions: []})
    end
  end

  describe "correct?/2 (boolean)" do
    setup :boolean_question

    test "returns true if both are true", %{true_question: q} do
      assert @test_module.correct?(q, true)
    end

    test "returns true if both are false", %{false_question: q} do
      assert @test_module.correct?(q, false)
    end

    test "returns false if correct is false but answer is true", %{false_question: q} do
      refute @test_module.correct?(q, true)
    end

    test "returns false if correct is false but answer is false", %{true_question: q} do
      refute @test_module.correct?(q, false)
    end
  end

  describe "correct?/2 (string)" do
    setup :string_question

    test "returns true if strings are equal", %{question: q} do
      assert @test_module.correct?(q, q.correct_answer)
    end

    test "returns false if strings are not equal", %{question: q} do
      refute @test_module.correct?(q, q.correct_answer |> String.reverse)
    end
  end

  describe "correct?/2 (list)" do
    setup :list_question

    test "correct if the two lists are equal", %{question: q} do
      assert @test_module.correct?(q, q.correct_answer)
    end

    test "correct if the two lists have the same elements but in different order", %{question: q} do
      assert @test_module.correct?(q, q.correct_answer |> :lists.reverse)
    end

    test "incorrect if the lists have different elements", %{question: q} do
      refute @test_module.correct?(q, ["hi" | q.correct_answer])
    end
  end

  describe "answer/2" do
    setup :make_session

    test "returns a :correct tuple if the answer is correct",
    %{session: %@test_module{questions: [q | _]} = session} do
      assert {:correct, _} = @test_module.answer(session, q.correct_answer)
    end

    test "returns a Session",
    %{session: %@test_module{questions: [q | _]} = session} do
      assert {_, %@test_module{}} =
        @test_module.answer(session, q.correct_answer)
    end

    test "puts the question into answered_questions",
    %{session: %@test_module{questions: [q | _]} = session} do
      answer = q.correct_answer
      assert {_, %@test_module{answered_questions: [{^q, _} | _]}} =
        @test_module.answer(session, answer)
    end

    test "records the answer that was given",
    %{session: %@test_module{questions: [q | _]} = session} do
      answer = q.correct_answer
      assert {_, %@test_module{answered_questions: [{^q, ^answer} | _]}} =
        @test_module.answer(session, answer)
    end
  end

  def make_session(_) do
    %@test_module{} = session = @test_module.new(@user, @topic)
    {:ok, %{session: session}}
  end

  def boolean_question(_) do
    true_question = %Question{correct_answer: true}
    false_question = %Question{correct_answer: false}

    %{true_question: true_question, false_question: false_question}
  end

  def string_question(_) do
    %{question: %Question{correct_answer: "abc"}}
  end

  def list_question(_) do
    %{question: %Question{correct_answer: ["abc", "def"]}}
  end
end
