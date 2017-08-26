defmodule OnCourse.Quiz.Question do
  @type choice :: String.t
  @type question_type ::
  {:multiple_choice, [choice]}
    | :text_input
    | :true_false

  defstruct [:correct_answer, :prompt, :question_type]

  @type answer :: String.t | [String.t] | boolean

  @type t :: %__MODULE__{
    prompt: String.t,
    question_type: question_type,
    correct_answer: answer
  }

  @type t(question_type) :: %__MODULE__{
    prompt: String.t,
    question_type: question_type,
    correct_answer: String.t | [String.t] | boolean
  }

  def multiple_choice({category_name, item_name}, item_index, category_index) do
    {choices, correct} =
    if correct?(category_name, item_name, item_index) do
      wrong =
        category_index
        |> Map.keys
        |> MapSet.new
        |> MapSet.difference(item_index |> Map.get(item_name) |> MapSet.new)
        |> Enum.take(3)

      correct =
        if length(wrong) == 3 do
          [category_name]
        else
          [category_name | Enum.take(item_index[item_name], 3 - length(wrong))] |> Enum.uniq
        end

      choices = correct ++ wrong
      {choices, correct}
    else
      correct = item_index[item_name] |> Enum.random

      other_choices =
        category_index
        |> Map.keys
        |> List.delete(category_name)
        |> Enum.take(2)

      wrong = [category_name | other_choices]
      choices = [correct | wrong]
      {choices, [correct]}
    end

    %__MODULE__{
      prompt: "Which category contains #{item_name}?",
      question_type: {:multiple_choice_single, choices |> Enum.uniq},
      correct_answer: correct
    }
  end

  def true_false({category_name, item_name}, item_index) do
    %__MODULE__{
      correct_answer: correct?(category_name, item_name, item_index),
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
end
