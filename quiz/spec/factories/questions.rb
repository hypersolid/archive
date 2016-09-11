FactoryGirl.define do
  factory :question do
    difficulty 1
    category_id 30
    question "Who is considered the Father of the Atomic Bomb?"
    correct_answer "Correct answer"
    wrong_answers ["Wrong answer 1", "Wrong answer 2"]
  end
end