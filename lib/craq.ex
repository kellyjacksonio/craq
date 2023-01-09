defmodule Craq do
  @moduledoc """
  Documentation for Craq.
  """

  def valid?([], _), do: true

  # Answers are required
  def valid?(questions, nil) do
    valid?(questions, %{})
  end

  def valid?(questions, answers) do
    questions
    |> Enum.with_index()
    |> Enum.reduce({false, %{}}, fn {question, question_index}, {questions_complete, acc} ->
      answer = Map.get(answers, "q#{question_index}")
      selected_option = get_selected_option(question, answer)
      answer_exists = answer_exists?(answer)
      answer_is_valid = answer_is_valid?(selected_option)

      errors =
        %{
          answer_exists: answer_exists,
          answer_is_valid: answer_is_valid,
          questions_complete: questions_complete
        }
        |> determine_error()
        |> format_error(question_index)

      {questions_complete || questions_complete?(selected_option), Map.merge(acc, errors)}
    end)
    |> parse_result()
  end

  defp determine_error(%{answer_exists: true, answer_is_valid: _, questions_complete: true}),
    do: "was answered even though a previous response indicated that the questions were complete"

  defp determine_error(%{
         answer_exists: true,
         answer_is_valid: false,
         questions_complete: _
       }),
       do: "has an answer that is not on the list of valid answers"

  defp determine_error(%{answer_exists: false, answer_is_valid: _, questions_complete: true}),
    do: nil

  defp determine_error(%{answer_exists: false, answer_is_valid: _, questions_complete: false}),
    do: "was not answered"

  defp determine_error(_), do: nil

  defp get_selected_option(_question, nil), do: nil

  defp get_selected_option(question, answer) do
    question
    |> Map.get(:options)
    |> case do
      nil ->
        nil

      options ->
        Enum.at(options, answer)
    end
  end

  defp answer_exists?(nil), do: false
  defp answer_exists?(_), do: true

  defp answer_is_valid?(nil), do: false
  defp answer_is_valid?(_), do: true

  defp format_error(nil, _question_index), do: %{}
  defp format_error(error, question_index), do: %{"q#{question_index}" => error}

  defp questions_complete?(nil), do: false

  defp questions_complete?(selected_option),
    do: Map.get(selected_option, :complete_if_selected, false)

  defp parse_result({_, errors}) when errors == %{}, do: true
  defp parse_result({_, errors}), do: errors
end
