defmodule CraqTest do
  use ExUnit.Case
  doctest Craq

  @valid_options [%{text: "an option"}, %{text: "another option"}]

  # Cases covered by https://gist.github.com/alexspeller/26d540731893141ab520f1c65fb2232e
  test "it is invalid with no answers" do
    questions = [%{text: "q1", options: @valid_options}]
    answers = %{}

    errors = Craq.valid?(questions, answers)
    assert %{"q0" => "was not answered"} == errors
  end

  test "it is invalid with nil answers" do
    questions = [%{text: "q1", options: @valid_options}]
    answers = nil

    errors = Craq.valid?(questions, answers)
    assert %{"q0" => "was not answered"} == errors
  end

  test "errors are added for all questions" do
    questions = [
      %{text: "q1", options: @valid_options},
      %{text: "q2", options: @valid_options}
    ]

    answers = nil

    errors = Craq.valid?(questions, answers)
    assert %{"q0" => "was not answered", "q1" => "was not answered"} == errors
  end

  test "it is valid when an answer is given" do
    questions = [%{text: "q1", options: [%{text: "yes"}, %{text: "no"}]}]
    answers = %{"q0" => 0}
    assert Craq.valid?(questions, answers) == true
  end

  test "it is valid when there are multiple options and the last option is chosen" do
    questions = [%{text: "q1", options: [%{text: "yes"}, %{text: "no"}, %{text: "maybe"}]}]
    answers = %{"q0" => 2}
    assert Craq.valid?(questions, answers) == true
  end

  test "it is invalid when an answer is not one of the valid answers" do
    questions = [%{text: "q1", options: @valid_options}]
    answers = %{"q0" => 2}
    errors = Craq.valid?(questions, answers)
    assert %{"q0" => "has an answer that is not on the list of valid answers"} == errors
  end

  test "it is invalid when not all the questions are answered" do
    questions = [
      %{text: "q1", options: @valid_options},
      %{text: "q2", options: @valid_options}
    ]

    answers = %{"q0" => 0}
    errors = Craq.valid?(questions, answers)
    assert %{"q1" => "was not answered"} = errors
  end

  test "it is valid when all the questions are answered" do
    questions = [
      %{text: "q1", options: @valid_options},
      %{text: "q2", options: @valid_options}
    ]

    answers = %{"q0" => 0, "q1" => 0}
    assert Craq.valid?(questions, answers) == true
  end

  test "it is valid when questions after complete_if_selected are not answered" do
    questions = [
      %{text: "q1", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
      %{text: "q2", options: @valid_options}
    ]

    answers = %{"q0" => 1}
    assert Craq.valid?(questions, answers) == true
  end

  test "it is invalid if questions after complete_if are answered" do
    questions = [
      %{text: "q1", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
      %{text: "q2", options: @valid_options}
    ]

    answers = %{"q0" => 1, "q1" => 0}

    errors = Craq.valid?(questions, answers)

    assert %{
             "q1" =>
               "was answered even though a previous response indicated that the questions were complete"
           } == errors
  end

  test "it is valid if complete_if is not a terminal answer and further questions are answered" do
    questions = [
      %{text: "q1", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
      %{text: "q2", options: @valid_options}
    ]

    answers = %{"q0" => 0, "q1" => 1}
    assert Craq.valid?(questions, answers) == true
  end

  test "it is invalid if complete_if is not a terminal answer and further questions are not answered" do
    questions = [
      %{text: "q1", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
      %{text: "q2", options: @valid_options}
    ]

    answers = %{"q0" => 0}

    errors = Craq.valid?(questions, answers)
    assert %{"q1" => "was not answered"} == errors
  end

  # Additional test cases
  test "it is valid with no questions and no answers" do
    questions = []
    answers = %{}

    assert Craq.valid?(questions, answers)
  end

  test "it is valid when questions before complete_if are answered" do
    questions = [
      %{text: "q1", options: @valid_options},
      %{text: "q2", options: [%{text: "yes"}, %{text: "no", complete_if_selected: true}]},
      %{text: "q3", options: @valid_options}
    ]

    answers = %{"q0" => 0, "q1" => 1}
    assert Craq.valid?(questions, answers) == true
  end

  test "it is valid with no question, regardless of answers" do
    questions = []
    answers = %{"q0" => 0}

    assert Craq.valid?(questions, answers)
  end
end
