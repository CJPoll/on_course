defmodule OnCourse.Web.Quizzes.View do
  use OnCourse.Web, :view

  @type class :: String.t
  @type option :: String.t
  @type responses :: [String.t]
  @type correct :: [String.t]

  @spec fieldset_class(option, responses, correct) :: class
  def fieldset_class(_option, [] = _responses, _correct), do: "answer-option"
  def fieldset_class(option, responses, correct)
  when is_list(responses) and is_list(correct) do
    cond do
      option in responses and option in correct ->
        "answer-option-correct"
      option in responses ->
        "answer-option-incorrect"
      option in correct ->
        "answer-option-should-be-correct"
      true ->
        "answer-option"
    end
  end
end
