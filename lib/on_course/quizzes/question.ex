defmodule OnCourse.Quizzes.Question do
  alias OnCourse.Quizzes.{Category, CategoryItem, MemoryQuestion, PromptQuestion}

  @type choice :: String.t
  @type question_type ::
    {:multiple_choice, [choice]}
      | :text_input
      | :true_false

  defstruct [:correct_answer, :prompt, :question_type]

  @type answer :: [String.t]

  @type item_index :: %{CategoryItem.name => [Category.name]}
  @type category_index :: %{Category.name => [CategoryItem.name]}

  @type t :: %__MODULE__{
    prompt: String.t,
    question_type: question_type,
    correct_answer: answer
  }

  @type t(question_type) :: %__MODULE__{
    prompt: String.t,
    question_type: question_type,
    correct_answer: answer
  }

  @max_option_count 4

  @spec review(t, answer)
  :: %{
    correct_answers: answer,
    missing_answers: answer,
    incorrect_answers: answer
  }

  def review(%__MODULE__{question_type: :true_false, correct_answer: true}, ["true"] = answer) do
    %{
      correct_answers: answer,
      missing_answers: [],
      incorrect_answers: []
    }
  end

  def review(%__MODULE__{question_type: :true_false, correct_answer: false}, ["false"] = answer) do
    %{
      correct_answers: answer,
      missing_answers: [],
      incorrect_answers: []
    }
  end

  def review(%__MODULE__{question_type: :true_false, correct_answer: correct_answer}, [answer]) do
    %{
      correct_answers: [],
      missing_answers: [to_string(correct_answer)],
      incorrect_answers: [answer]
    }
  end

  def review(%__MODULE__{question_type: :hidden, correct_answer: correct_answer}, _) do
    %{
      correct_answers: correct_answer,
      missing_answers: [],
      incorrect_answers: []
    }
  end

  @spec multiple_choice({Category.name, CategoryItem.name}, item_index, category_index)
  :: t
  def multiple_choice({category_name, item_name}, item_index, category_index) do
    {choices, correct} =
    if correct?(category_name, item_name, item_index) do
      wrong =
        category_index
        |> Map.keys
        |> MapSet.new
        |> MapSet.difference(item_index |> Map.get(item_name) |> MapSet.new)
        |> Enum.take(@max_option_count - 1)

      correct =
        if length(wrong) == (@max_option_count - 1) do
          [category_name]
        else
          [category_name | Enum.take(item_index[item_name], @max_option_count - 1 - length(wrong))] |> Enum.uniq
        end

      choices = correct ++ wrong
      {choices, correct}
    else
      correct = item_index[item_name] |> Enum.random

      other_choices =
        category_index
        |> Map.keys
        |> List.delete(category_name)
        |> Enum.take(@max_option_count - 2)

      wrong = [category_name | other_choices]
      choices = [correct | wrong]
      {choices, [correct]}
    end

    %__MODULE__{
      prompt: "Which category contains #{item_name}?",
      question_type: {:multiple_choice, choices |> Enum.uniq},
      correct_answer: correct
    }
  end

  @spec true_false({Category.name, CategoryItem.name}, %{CategoryItem.name => [Category.name]})
  :: t(:true_false)
  def true_false({category_name, item_name}, item_index) do
    %__MODULE__{
      correct_answer: [correct?(category_name, item_name, item_index) |> to_string],
      prompt: "Is #{item_name} in the category of #{category_name}?",
      question_type: :true_false
    }
  end

  def true_false(cross_join, index) when is_map(cross_join) do
    Enum.map(cross_join, fn(e) -> true_false(e, index) end)
  end

  def correct?(category_name, item_name, item_index) do
    category_name in item_index[item_name]
  end

  def from_prompt_question(%PromptQuestion{} = q) do
    %__MODULE__{
      correct_answer: [q.correct_answer],
      prompt: q.prompt,
      question_type: :text_input
    }
  end

  def from_memory_question(%MemoryQuestion{} = q) do
    %__MODULE__{
      correct_answer: Enum.map(q.memory_answers, fn(%{text: answer}) -> answer end),
      prompt: q.prompt,
      question_type: :hidden
    } |> IO.inspect
  end
end

defimpl Poison.Encoder, for: OnCourse.Quizzes.Question do
  def encode(%OnCourse.Quizzes.Question{} = question, _options) do
    map =
      case question.question_type do
        :hidden ->
          %{"prompt" => question.prompt, "question_type" => "hidden"}
        :text_input ->
          %{"prompt" => question.prompt, "question_type" => "text_input"}
        :true_false ->
          %{"prompt" => question.prompt, "question_type" => "true_false"}
        {:multiple_choice, choices} ->
          %{"prompt" => question.prompt, "question_type" => "multiple_choice", "choices" => choices}
      end

    Poison.encode!(map)
  end
end
