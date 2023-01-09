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

      answer = get_answer(question_index, answers)
      selected_option = get_selected_option(question, answer)

      answer_exist_error = find_answer(question_index, answer, questions_complete)
      answer_valid_error = if (answer_exist_error == %{}) do
        validate_answer(question_index, selected_option, questions_complete)
      else
        %{}
      end

      questions_complete = if (!questions_complete), do: questions_complete?(selected_option), else: true


      acc = acc
      |> Map.merge(answer_exist_error)
      |> Map.merge(answer_valid_error)

      {questions_complete, acc}
    end)
    |> parse_result()
  end

  defp get_answer(question_index, answers) do
    Map.get(answers, "q#{question_index}")
  end

  defp get_selected_option(_question, nil), do: nil

  defp get_selected_option(question, answer) do
    question
    |> Map.get(:options)
    |> case do
      nil -> nil
      options ->
        Enum.at(options, answer)
    end
  end

  defp find_answer(_question_index, _answer, true), do: %{}

  defp find_answer(question_index, nil, _questions_complete), do: %{ "q#{question_index}" => "was not answered"}

  defp find_answer(_question_index, _answer, _questions_complete), do: %{}

  defp validate_answer(_question_index, nil, true), do: %{}

  defp validate_answer(question_index, nil, _questions_complete), do:
    %{ "q#{question_index}" => "has an answer that is not on the list of valid answers"}

  defp validate_answer(question_index, _, true), do:
    %{ "q#{question_index}" => "was answered even though a previous response indicated that the questions were complete"}

  defp validate_answer(_, _, _), do: %{}

  defp questions_complete?(nil), do: false

  defp questions_complete?(selected_option) do
    Map.get(selected_option, :complete_if_selected, false)
  end

  defp parse_result({_, errors}) when errors == %{}, do: true

  defp parse_result({_, errors}), do: errors
end
